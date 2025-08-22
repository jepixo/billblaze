// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sized_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetSizedItemAdapter extends TypeAdapter<SheetSizedItem> {
  @override
  final int typeId = 23;

  @override
  SheetSizedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetSizedItem(
      id: fields[0] as String,
      parentId: fields[1] as String,
      indexPath: fields[2] as IndexPath,
      width: fields[3] as double,
      height: fields[4] as double,
      hide: fields[6] as bool,
      sizedItemDecoration: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetSizedItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(3)
      ..write(obj.width)
      ..writeByte(4)
      ..write(obj.height)
      ..writeByte(5)
      ..write(obj.sizedItemDecoration)
      ..writeByte(6)
      ..write(obj.hide)
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
      other is SheetSizedItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
