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
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableBox obj) {
    writer
      ..writeByte(11)
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

class ValidationRuleBoxAdapter extends TypeAdapter<ValidationRuleBox> {
  @override
  final int typeId = 13;

  @override
  ValidationRuleBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ValidationRuleBox(
      type: fields[0] as int,
      required: fields[1] as bool,
      regexPattern: fields[2] as String?,
      allowedValues: (fields[3] as List?)?.cast<String>(),
      customMessage: fields[4] as String?,
      customFunction: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ValidationRuleBox obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.required)
      ..writeByte(2)
      ..write(obj.regexPattern)
      ..writeByte(3)
      ..write(obj.allowedValues)
      ..writeByte(4)
      ..write(obj.customMessage)
      ..writeByte(5)
      ..write(obj.customFunction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationRuleBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
