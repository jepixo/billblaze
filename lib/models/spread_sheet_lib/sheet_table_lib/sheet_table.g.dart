// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetTableBoxAdapter extends TypeAdapter<SheetTableBox> {
  @override
  final int typeId = 9;

  @override
  SheetTableBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      cellData: (fields[3] as List)
          .map((dynamic e) => (e as List).cast<SheetTableCellBox>())
          .toList(),
      rowData: (fields[4] as List).cast<SheetTableRowBox>(),
      columnData: (fields[5] as List).cast<SheetTableColumnBox>(),
      pinnedRows: fields[6] as int,
      pinnedColumns: fields[7] as int,
      sheetTableDecoration: fields[8] as SuperDecorationBox,
      sheetTablebgDecoration: fields[9] as SuperDecorationBox?,
      indexPath: fields[2] as IndexPath,
      name: fields[10] as String,
      expand: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableBox obj) {
    writer
      ..writeByte(12)
      ..writeByte(3)
      ..write(obj.cellData)
      ..writeByte(4)
      ..write(obj.rowData)
      ..writeByte(5)
      ..write(obj.columnData)
      ..writeByte(6)
      ..write(obj.pinnedRows)
      ..writeByte(7)
      ..write(obj.pinnedColumns)
      ..writeByte(8)
      ..write(obj.sheetTableDecoration)
      ..writeByte(9)
      ..write(obj.sheetTablebgDecoration)
      ..writeByte(10)
      ..write(obj.name)
      ..writeByte(11)
      ..write(obj.expand)
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
      other is SheetTableBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
