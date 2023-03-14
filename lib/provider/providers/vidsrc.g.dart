// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vidsrc.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VidSrcAdapter extends TypeAdapter<VidSrc> {
  @override
  final int typeId = 3;

  @override
  VidSrc read(BinaryReader reader) {
    return VidSrc();
  }

  @override
  void write(BinaryWriter writer, VidSrc obj) {
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
      other is VidSrcAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
