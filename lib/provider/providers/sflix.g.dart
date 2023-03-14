// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sflix.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SflixAdapter extends TypeAdapter<Sflix> {
  @override
  final int typeId = 2;

  @override
  Sflix read(BinaryReader reader) {
    return Sflix();
  }

  @override
  void write(BinaryWriter writer, Sflix obj) {
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
      other is SflixAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
