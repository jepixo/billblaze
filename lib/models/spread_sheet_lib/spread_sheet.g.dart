// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spread_sheet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetItemAdapter extends TypeAdapter<SheetItem> {
  @override
  final int typeId = 1;

  @override
  SheetItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetItem(
      id: fields[0] as String,
      parentId: fields[1] as String,
      itemDecoration: (fields[2] as List).cast<dynamic>(),
      decorationId: fields[3] as String,
      decorationName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.itemDecoration)
      ..writeByte(3)
      ..write(obj.decorationId)
      ..writeByte(4)
      ..write(obj.decorationName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
