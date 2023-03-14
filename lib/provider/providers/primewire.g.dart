// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'primewire.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrimeWireAdapter extends TypeAdapter<PrimeWire> {
  @override
  final int typeId = 8;

  @override
  PrimeWire read(BinaryReader reader) {
    return PrimeWire();
  }

  @override
  void write(BinaryWriter writer, PrimeWire obj) {
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
      other is PrimeWireAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
