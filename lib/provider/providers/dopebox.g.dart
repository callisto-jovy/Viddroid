// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dopebox.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DopeBoxAdapter extends TypeAdapter<DopeBox> {
  @override
  final int typeId = 6;

  @override
  DopeBox read(BinaryReader reader) {
    return DopeBox();
  }

  @override
  void write(BinaryWriter writer, DopeBox obj) {
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
      other is DopeBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
