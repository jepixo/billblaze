// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_table_column.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetTableColumnBoxAdapter extends TypeAdapter<SheetTableColumnBox> {
  @override
  final int typeId = 12;

  @override
  SheetTableColumnBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableColumnBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      size: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableColumnBox obj) {
    writer
      ..writeByte(3)
      ..writeByte(2)
      ..write(obj.size)
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
      other is SheetTableColumnBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
