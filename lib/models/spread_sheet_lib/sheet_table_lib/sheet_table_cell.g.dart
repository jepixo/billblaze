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
      data: fields[3] as String,
      sheetItem: fields[4] as SheetItem,
      isVisible: fields[5] as bool,
      hasError: fields[6] as bool,
      colSpan: fields[8] as int,
      rowSpan: fields[7] as int,
      errorMessage: fields[10] as String?,
      validationRule: fields[11] as ValidationRuleBox?,
      ownerId: fields[9] as String?,
      indexPath: fields[2] as IndexPath,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableCellBox obj) {
    writer
      ..writeByte(12)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.sheetItem)
      ..writeByte(5)
      ..write(obj.isVisible)
      ..writeByte(6)
      ..write(obj.hasError)
      ..writeByte(7)
      ..write(obj.rowSpan)
      ..writeByte(8)
      ..write(obj.colSpan)
      ..writeByte(9)
      ..write(obj.ownerId)
      ..writeByte(10)
      ..write(obj.errorMessage)
      ..writeByte(11)
      ..write(obj.validationRule)
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
      other is SheetTableCellBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
