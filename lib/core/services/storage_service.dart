import 'package:hive_flutter/hive_flutter.dart';
import '../../features/onboarding/data/models/user_model.dart';
import '../../features/courses/data/models/course.dart';
import '../../features/courses/data/models/pending_lesson.dart';
import '../../features/courses/data/models/lesson_note.dart';

class StorageService {
  static const String userBoxName = 'userBox';
  static const String coursesBoxName = 'coursesBox';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(CourseAdapter());
    Hive.registerAdapter(PendingLessonAdapter());
    Hive.registerAdapter(LessonNoteAdapter());

    // Open Component-specific Boxes
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<Course>(coursesBoxName);
  }

  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  Box<Course> get coursesBox => Hive.box<Course>(coursesBoxName);
}
