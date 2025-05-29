// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_table_row.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetTableRowBoxAdapter extends TypeAdapter<SheetTableRowBox> {
  @override
  final int typeId = 11;

  @override
  SheetTableRowBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableRowBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      size: fields[2] as double,
      minSize: fields[3] as double,
      maxSize: fields[4] as double,
      hide: fields[5] as bool,
      rowDecoration: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableRowBox obj) {
    writer
      ..writeByte(7)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.minSize)
      ..writeByte(4)
      ..write(obj.maxSize)
      ..writeByte(5)
      ..write(obj.hide)
      ..writeByte(6)
      ..write(obj.rowDecoration)
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
      other is SheetTableRowBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
