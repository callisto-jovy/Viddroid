// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goku.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GokuAdapter extends TypeAdapter<Goku> {
  @override
  final int typeId = 9;

  @override
  Goku read(BinaryReader reader) {
    return Goku();
  }

  @override
  void write(BinaryWriter writer, Goku obj) {
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
      other is GokuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
