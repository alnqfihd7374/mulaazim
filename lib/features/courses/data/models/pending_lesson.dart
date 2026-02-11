import 'package:hive/hive.dart';

part 'pending_lesson.g.dart';

@HiveType(typeId: 2)
class PendingLesson extends HiveObject {
  @HiveField(0)
  final int lessonNumber;

  @HiveField(1)
  final DateTime missedDate;

  @HiveField(2)
  final String? reason;

  @HiveField(3)
  final bool isHeard; // Has it been listened to?

  @HiveField(4)
  final DateTime? makeUpDate;

  PendingLesson({
    required this.lessonNumber,
    required this.missedDate,
    this.reason,
    this.isHeard = false,
    this.makeUpDate,
  });
}
