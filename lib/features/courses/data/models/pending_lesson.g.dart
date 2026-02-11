// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingLessonAdapter extends TypeAdapter<PendingLesson> {
  @override
  final int typeId = 2;

  @override
  PendingLesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingLesson(
      lessonNumber: fields[0] as int,
      missedDate: fields[1] as DateTime,
      reason: fields[2] as String?,
      isHeard: fields[3] as bool,
      makeUpDate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingLesson obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.lessonNumber)
      ..writeByte(1)
      ..write(obj.missedDate)
      ..writeByte(2)
      ..write(obj.reason)
      ..writeByte(3)
      ..write(obj.isHeard)
      ..writeByte(4)
      ..write(obj.makeUpDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingLessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
