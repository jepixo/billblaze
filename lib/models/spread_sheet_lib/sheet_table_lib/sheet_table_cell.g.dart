// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_table_cell.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetTableCellBoxAdapter extends TypeAdapter<SheetTableCellBox> {
  @override
  final int typeId = 10;

  @override
  SheetTableCellBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableCellBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      data: fields[2] as String,
      sheetItem: fields[3] as SheetItem,
      isLocked: fields[4] as bool,
      hasError: fields[5] as bool,
      colSpan: fields[7] as int,
      rowSpan: fields[6] as int,
      errorMessage: fields[9] as String?,
      validationRule: fields[10] as ValidationRuleBox?,
      ownerId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableCellBox obj) {
    writer
      ..writeByte(11)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.sheetItem)
      ..writeByte(4)
      ..write(obj.isLocked)
      ..writeByte(5)
      ..write(obj.hasError)
      ..writeByte(6)
      ..write(obj.rowSpan)
      ..writeByte(7)
      ..write(obj.colSpan)
      ..writeByte(8)
      ..write(obj.ownerId)
      ..writeByte(9)
      ..write(obj.errorMessage)
      ..writeByte(10)
      ..write(obj.validationRule)
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
      other is SheetTableCellBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
