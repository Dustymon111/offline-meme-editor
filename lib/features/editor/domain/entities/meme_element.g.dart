// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meme_element.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemeElementAdapter extends TypeAdapter<MemeElement> {
  @override
  final int typeId = 2;

  @override
  MemeElement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemeElement(
      id: fields[0] as String?,
      type: fields[1] as MemeElementType,
      x: fields[2] as double,
      y: fields[3] as double,
      content: fields[4] as String,
      scale: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MemeElement obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.x)
      ..writeByte(3)
      ..write(obj.y)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.scale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemeElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MemeElementTypeAdapter extends TypeAdapter<MemeElementType> {
  @override
  final int typeId = 1;

  @override
  MemeElementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemeElementType.text;
      case 1:
        return MemeElementType.sticker;
      default:
        return MemeElementType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MemeElementType obj) {
    switch (obj) {
      case MemeElementType.text:
        writer.writeByte(0);
        break;
      case MemeElementType.sticker:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemeElementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
