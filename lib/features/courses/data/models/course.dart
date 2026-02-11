import 'package:hive/hive.dart';
import 'pending_lesson.dart';
import 'lesson_note.dart';

part 'course.g.dart';

@HiveType(typeId: 1)
class Course extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bookName;

  @HiveField(2)
  final String teacherName;

  @HiveField(3)
  final String teacherTitle; // Sheikh / Brother

  @HiveField(4)
  final List<int> scheduleDays; // 1 = Monday, 7 = Sunday (DateTime.weekday)

  @HiveField(5)
  final int currentLessonNumber;

  @HiveField(6)
  final List<PendingLesson> pendingLessons;

  @HiveField(7)
  final List<LessonNote> notes;
  
  @HiveField(8)
  final DateTime? lastCheckInDate;

  @HiveField(9)
  final String? reminderTime; // Format "HH:mm"

  Course({
    required this.id,
    required this.bookName,
    required this.teacherName,
    required this.teacherTitle,
    required this.scheduleDays,
    required this.currentLessonNumber,
    this.pendingLessons = const [],
    this.notes = const [],
    this.lastCheckInDate,
    this.reminderTime,
  });

  Course copyWith({
    String? bookName,
    String? teacherName,
    String? teacherTitle,
    List<int>? scheduleDays,
    int? currentLessonNumber,
    List<PendingLesson>? pendingLessons,
    List<LessonNote>? notes,
    DateTime? lastCheckInDate,
    String? reminderTime,
  }) {
    return Course(
      id: id,
      bookName: bookName ?? this.bookName,
      teacherName: teacherName ?? this.teacherName,
      teacherTitle: teacherTitle ?? this.teacherTitle,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      currentLessonNumber: currentLessonNumber ?? this.currentLessonNumber,
      pendingLessons: pendingLessons ?? this.pendingLessons,
      notes: notes ?? this.notes,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
