// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Movies123Adapter extends TypeAdapter<Movies_123> {
  @override
  final int typeId = 1;

  @override
  Movies_123 read(BinaryReader reader) {
    return Movies_123();
  }

  @override
  void write(BinaryWriter writer, Movies_123 obj) {
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
      other is Movies123Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
