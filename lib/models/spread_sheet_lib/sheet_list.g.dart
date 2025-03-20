// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetListBoxAdapter extends TypeAdapter<SheetListBox> {
  @override
  final int typeId = 2;

  @override
  SheetListBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetListBox(
      sheetList: (fields[5] as List).cast<SheetItem>(),
      direction: fields[6] as bool,
      id: fields[0] as String,
      parentId: fields[1] as String,
      decorationId: fields[3] as String,
      itemDecoration: (fields[2] as List).cast<dynamic>(),
      size: (fields[7] as List).cast<dynamic>(),
      mainAxisAlignment: fields[8] as int,
      crossAxisAlignment: fields[9] as int,
    )..decorationName = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, SheetListBox obj) {
    writer
      ..writeByte(10)
      ..writeByte(5)
      ..write(obj.sheetList)
      ..writeByte(6)
      ..write(obj.direction)
      ..writeByte(7)
      ..write(obj.size)
      ..writeByte(8)
      ..write(obj.mainAxisAlignment)
      ..writeByte(9)
      ..write(obj.crossAxisAlignment)
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
      other is SheetListBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
