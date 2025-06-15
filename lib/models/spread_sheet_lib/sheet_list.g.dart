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
      sheetList: (fields[3] as List).cast<SheetItem>(),
      direction: fields[4] as bool,
      id: fields[0] as String,
      parentId: fields[1] as String,
      mainAxisAlignment: fields[5] as int,
      crossAxisAlignment: fields[6] as int,
      mainAxisSize: fields[8] as int,
      decorationId: fields[7] as String,
      indexPath: fields[2] as IndexPath,
      size: (fields[9] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SheetListBox obj) {
    writer
      ..writeByte(10)
      ..writeByte(3)
      ..write(obj.sheetList)
      ..writeByte(4)
      ..write(obj.direction)
      ..writeByte(5)
      ..write(obj.mainAxisAlignment)
      ..writeByte(6)
      ..write(obj.crossAxisAlignment)
      ..writeByte(7)
      ..write(obj.decorationId)
      ..writeByte(8)
      ..write(obj.mainAxisSize)
      ..writeByte(9)
      ..write(obj.size)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath);
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
