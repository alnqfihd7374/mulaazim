import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/repositories/course_repository.dart';

import '../../data/models/course.dart';
import '../../data/models/pending_lesson.dart';
import '../../data/models/lesson_note.dart';


// Events
abstract class CourseEvent extends Equatable {

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {}

class AddCourseEvent extends CourseEvent {
  final String bookName;
  final String teacherName;
  final String teacherTitle;
  final List<int> scheduleDays;
  final int currentLessonNumber;
  final String? reminderTime;

  AddCourseEvent({
    required this.bookName,
    required this.teacherName,
    required this.teacherTitle,
    required this.scheduleDays,
    required this.currentLessonNumber,
    this.reminderTime,
  });

  @override
  List<Object?> get props => [bookName, teacherName, teacherTitle, scheduleDays, currentLessonNumber, reminderTime];
}

class UpdateCourseEvent extends CourseEvent {
  final Course course;

  UpdateCourseEvent(this.course);

  @override
  List<Object?> get props => [course];
}

class DeleteCourseEvent extends CourseEvent {
  final String courseId;

  DeleteCourseEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class CheckInEvent extends CourseEvent {
  final Course course;
  final CheckInStatus status;
  final String? excuseReason; // For 'Missed'
  
  CheckInEvent({
    required this.course,
    required this.status,
    this.excuseReason,
  });

  @override
  List<Object?> get props => [course, status, excuseReason];
}

enum CheckInStatus { attended, missed, excuse }

class MarkLessonAsDone extends CourseEvent {
  final Course course;
  final PendingLesson lesson;

  MarkLessonAsDone({required this.course, required this.lesson});

  @override
  List<Object?> get props => [course, lesson];
}

class AddNoteEvent extends CourseEvent {
  final Course course;
  final String content;
  final int lessonNumber;

  AddNoteEvent({
    required this.course,
    required this.content,
    required this.lessonNumber,
  });

  @override
  List<Object?> get props => [course, content, lessonNumber];
}

class UpdateNoteEvent extends CourseEvent {
  final Course course;
  final LessonNote oldNote;
  final String newContent;
  final int newLessonNumber;

  UpdateNoteEvent({
    required this.course, 
    required this.oldNote, 
    required this.newContent,
    required this.newLessonNumber,
  });

  @override
  List<Object?> get props => [course, oldNote, newContent, newLessonNumber];
}

class DeleteNoteEvent extends CourseEvent {
  final Course course;
  final LessonNote note;

  DeleteNoteEvent({required this.course, required this.note});

  @override
  List<Object?> get props => [course, note];
}




// States
abstract class CourseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Course> courses;

  CourseLoaded({required this.courses});

  @override
  List<Object?> get props => [courses];
}

class CourseOperationSuccess extends CourseState {
  final String message;

  CourseOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CourseFailure extends CourseState {
  final String message;

  CourseFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository courseRepository;
  final NotificationService notificationService;

  CourseBloc({
    required this.courseRepository,
    required this.notificationService,
  }) : super(CourseInitial()) {

    on<LoadCourses>((event, emit) async {
      emit(CourseLoading());
      final result = await courseRepository.getCourses();
      result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (courses) => emit(CourseLoaded(courses: courses)),
      );
    });

    on<AddCourseEvent>((event, emit) async {
      emit(CourseLoading());
      
      final newCourse = Course(
        id: const Uuid().v4(),
        bookName: event.bookName,
        teacherName: event.teacherName,
        teacherTitle: event.teacherTitle,
        scheduleDays: event.scheduleDays,
        currentLessonNumber: event.currentLessonNumber,
        reminderTime: event.reminderTime,
      );

      final result = await courseRepository.addCourse(newCourse);

      result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          if (newCourse.reminderTime != null) {
             notificationService.scheduleCourseReminder(newCourse);
          }
          emit(CourseOperationSuccess('تم إضافة المادة بنجاح'));
          add(LoadCourses()); // Reload list
        },
      );
    });

    on<UpdateCourseEvent>((event, emit) async {
       emit(CourseLoading());
       final result = await courseRepository.updateCourse(event.course);
       result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          if (event.course.reminderTime != null) {
            notificationService.scheduleCourseReminder(event.course);
          }
          emit(CourseOperationSuccess('تم تحديث المادة بنجاح'));
          add(LoadCourses());
        },
      );
    });
    
    on<DeleteCourseEvent>((event, emit) async {
       emit(CourseLoading());
       final result = await courseRepository.deleteCourse(event.courseId);
       result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          emit(CourseOperationSuccess('تم حذف المادة'));
          add(LoadCourses());
        },
      );
    });

    on<CheckInEvent>((event, emit) async {
       emit(CourseLoading());
       
       Course updatedCourse = event.course;
       final now = DateTime.now();
       
       if (event.status == CheckInStatus.attended) {
         updatedCourse = updatedCourse.copyWith(
           currentLessonNumber: updatedCourse.currentLessonNumber + 1,
           lastCheckInDate: now,
         );
       } else if (event.status == CheckInStatus.missed) {
         final pending = PendingLesson(
           lessonNumber: updatedCourse.currentLessonNumber,
           missedDate: now,
           reason: event.excuseReason,
         );
         
         final List<PendingLesson> newPendingList = List.from(updatedCourse.pendingLessons)..add(pending);
         
         updatedCourse = updatedCourse.copyWith(
           currentLessonNumber: updatedCourse.currentLessonNumber + 1,
           pendingLessons: newPendingList,
           lastCheckInDate: now,
         );
       } else if (event.status == CheckInStatus.excuse) {
         updatedCourse = updatedCourse.copyWith(
           lastCheckInDate: now,
         );
       }

       final result = await courseRepository.updateCourse(updatedCourse);
       result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          add(LoadCourses());
        },
      );
    });

    on<MarkLessonAsDone>((event, emit) async {
       emit(CourseLoading());
       
       final course = event.course;
       final pendingLesson = event.lesson;
       
       final updatedList = course.pendingLessons.map((p) {
         if (p.lessonNumber == pendingLesson.lessonNumber && 
             p.missedDate.day == pendingLesson.missedDate.day &&
             p.missedDate.month == pendingLesson.missedDate.month) {
           return PendingLesson(
             lessonNumber: p.lessonNumber,
             missedDate: p.missedDate,
             reason: p.reason,
             isHeard: true,
           );
         }
         return p;
       }).toList();
       
       final updatedCourse = course.copyWith(pendingLessons: updatedList);

       final result = await courseRepository.updateCourse(updatedCourse);
       result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          add(LoadCourses());
        },
      );
    });

    on<AddNoteEvent>((event, emit) async {
       emit(CourseLoading());
       
       final course = event.course;
       
       final newNote = LessonNote(
         lessonNumber: event.lessonNumber,
         content: event.content,
         createdAt: DateTime.now(),
       );
       
       final List<LessonNote> updatedNotes = List.from(course.notes)..add(newNote);
       final updatedCourse = course.copyWith(notes: updatedNotes);

       final result = await courseRepository.updateCourse(updatedCourse);
       result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          emit(CourseOperationSuccess('تم حفظ الفائدة'));
          add(LoadCourses());
        },
      );
    });

    on<UpdateNoteEvent>((event, emit) async {
       emit(CourseLoading());
       
       final List<LessonNote> updatedNotes = event.course.notes.map((n) {
          if (n.createdAt == event.oldNote.createdAt && n.content == event.oldNote.content) {
            return LessonNote(
              lessonNumber: event.newLessonNumber,
              content: event.newContent,
              createdAt: n.createdAt,
            );
          }
          return n;
       }).toList();
       
       final updatedCourse = event.course.copyWith(notes: updatedNotes);
       final result = await courseRepository.updateCourse(updatedCourse);
       
       result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          emit(CourseOperationSuccess('تم تحديث الفائدة'));
          add(LoadCourses());
        },
      );
    });

    on<DeleteNoteEvent>((event, emit) async {
       emit(CourseLoading());
       
       final List<LessonNote> updatedNotes = event.course.notes.where((n) => 
         !(n.createdAt == event.note.createdAt && n.content == event.note.content)
       ).toList();
       
       final updatedCourse = event.course.copyWith(notes: updatedNotes);
       final result = await courseRepository.updateCourse(updatedCourse);
       
       result.fold(
        (failure) => emit(CourseFailure(_mapFailureToMessage(failure))),
        (_) {
          emit(CourseOperationSuccess('تم حذف الفائدة'));
          add(LoadCourses());
        },
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is CacheFailure) {
      return 'Cache Failure';
    } else {
      return 'Unexpected Error';
    }
  }
}
