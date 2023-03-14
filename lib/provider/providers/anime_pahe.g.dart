// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_pahe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimePaheAdapter extends TypeAdapter<AnimePahe> {
  @override
  final int typeId = 5;

  @override
  AnimePahe read(BinaryReader reader) {
    return AnimePahe();
  }

  @override
  void write(BinaryWriter writer, AnimePahe obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.mainUrl)
      ..writeByte(2)
      ..write(obj.types)
      ..writeByte(3)
      ..write(obj.language);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimePaheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
