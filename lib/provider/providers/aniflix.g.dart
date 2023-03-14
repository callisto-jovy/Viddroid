// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aniflix.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AniflixAdapter extends TypeAdapter<Aniflix> {
  @override
  final int typeId = 4;

  @override
  Aniflix read(BinaryReader reader) {
    return Aniflix();
  }

  @override
  void write(BinaryWriter writer, Aniflix obj) {
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
      other is AniflixAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
