// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TvTypeAdapter extends TypeAdapter<TvType> {
  @override
  final int typeId = 69;

  @override
  TvType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TvType.movie;
      case 1:
        return TvType.tv;
      case 2:
        return TvType.anime;
      default:
        return TvType.movie;
    }
  }

  @override
  void write(BinaryWriter writer, TvType obj) {
    switch (obj) {
      case TvType.movie:
        writer.writeByte(0);
        break;
      case TvType.tv:
        writer.writeByte(1);
        break;
      case TvType.anime:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TvTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
