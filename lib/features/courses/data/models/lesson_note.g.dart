// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonNoteAdapter extends TypeAdapter<LessonNote> {
  @override
  final int typeId = 3;

  @override
  LessonNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonNote(
      lessonNumber: fields[0] as int,
      content: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LessonNote obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lessonNumber)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
