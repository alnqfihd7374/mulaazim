import 'package:hive/hive.dart';

part 'lesson_note.g.dart';

@HiveType(typeId: 3)
class LessonNote extends HiveObject {
  @HiveField(0)
  final int lessonNumber;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createdAt;

  LessonNote({
    required this.lessonNumber,
    required this.content,
    required this.createdAt,
  });
}
