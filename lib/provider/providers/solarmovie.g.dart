// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solarmovie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SolarMovieAdapter extends TypeAdapter<SolarMovie> {
  @override
  final int typeId = 10;

  @override
  SolarMovie read(BinaryReader reader) {
    return SolarMovie();
  }

  @override
  void write(BinaryWriter writer, SolarMovie obj) {
    writer
      ..writeByte(2)
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
      other is SolarMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
