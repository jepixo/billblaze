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
      size: fields[3] as double,
      minSize: fields[4] as double,
      maxSize: fields[5] as double,
      hide: fields[6] as bool,
      columnDecoration: fields[7] as String,
      indexPath: fields[2] as IndexPath,
      columnInputBlocks: (fields[8] as List).cast<InputBlock>(),
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableColumnBox obj) {
    writer
      ..writeByte(9)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.minSize)
      ..writeByte(5)
      ..write(obj.maxSize)
      ..writeByte(6)
      ..write(obj.hide)
      ..writeByte(7)
      ..write(obj.columnDecoration)
      ..writeByte(8)
      ..write(obj.columnInputBlocks)
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
      other is SheetTableColumnBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
