// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetItemAdapter extends TypeAdapter<SheetItem> {
  @override
  final int typeId = 1;

  @override
  SheetItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetItem(
      id: fields[0] as String,
      parentId: fields[1] as String,
      indexPath: fields[2] as IndexPath,
    );
  }

  @override
  void write(BinaryWriter writer, SheetItem obj) {
    writer
      ..writeByte(3)
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
      other is SheetItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
