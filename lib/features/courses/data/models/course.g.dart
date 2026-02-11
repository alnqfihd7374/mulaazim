// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseAdapter extends TypeAdapter<Course> {
  @override
  final int typeId = 1;

  @override
  Course read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Course(
      id: fields[0] as String,
      bookName: fields[1] as String,
      teacherName: fields[2] as String,
      teacherTitle: fields[3] as String,
      scheduleDays: (fields[4] as List).cast<int>(),
      currentLessonNumber: fields[5] as int,
      pendingLessons: (fields[6] as List).cast<PendingLesson>(),
      notes: (fields[7] as List).cast<LessonNote>(),
      lastCheckInDate: fields[8] as DateTime?,
      reminderTime: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Course obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookName)
      ..writeByte(2)
      ..write(obj.teacherName)
      ..writeByte(3)
      ..write(obj.teacherTitle)
      ..writeByte(4)
      ..write(obj.scheduleDays)
      ..writeByte(5)
      ..write(obj.currentLessonNumber)
      ..writeByte(6)
      ..write(obj.pendingLessons)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.lastCheckInDate)
      ..writeByte(9)
      ..write(obj.reminderTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
