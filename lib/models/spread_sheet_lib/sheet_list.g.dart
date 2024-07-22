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
      sheetList: (fields[2] as List).cast<SheetItem>(),
      direction: fields[3] as bool,
      id: fields[0] as String,
      parentId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetListBox obj) {
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
      other is SheetListBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
