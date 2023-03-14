// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hdtoday.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HdTodayAdapter extends TypeAdapter<HdToday> {
  @override
  final int typeId = 7;

  @override
  HdToday read(BinaryReader reader) {
    return HdToday();
  }

  @override
  void write(BinaryWriter writer, HdToday obj) {
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
      other is HdTodayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
