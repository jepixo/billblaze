// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetListAdapter extends TypeAdapter<SheetList> {
  @override
  final int typeId = 2;

  @override
  SheetList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetList(
      id: fields[0] as String,
      parentId: fields[1] as String,
      sheetList: (fields[2] as List).cast<SheetItem>(),
      direction: fields[3] as Axis,
    );
  }

  @override
  void write(BinaryWriter writer, SheetList obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.sheetList)
      ..writeByte(3)
      ..write(obj.direction)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
