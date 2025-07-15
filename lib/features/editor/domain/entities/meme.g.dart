// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemeAdapter extends TypeAdapter<Meme> {
  @override
  final int typeId = 0;

  @override
  Meme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meme(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      elements: (fields[2] as List).cast<MemeElement>(),
    );
  }

  @override
  void write(BinaryWriter writer, Meme obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.elements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
