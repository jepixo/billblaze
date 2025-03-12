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
      sheetList: (fields[2] as List).cast<SheetItem>(),
      direction: fields[3] as bool,
      id: fields[0] as String,
      parentId: fields[1] as String,
      size: (fields[4] as List).cast<dynamic>(),
      padding: (fields[5] as List).cast<double>(),
      mainAxisAlignment: fields[6] as String,
      crossAxisAlignment: fields[7] as String,
      image: fields[9] as Uint8List?,
      imageFit: fields[10] as String,
      color: fields[11] as String,
      borderColor: fields[12] as String,
      borderRadius: (fields[14] as List).cast<double>(),
      borderWidth: (fields[13] as List).cast<double>(),
      widthAdjustment: (fields[8] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SheetListBox obj) {
    writer
      ..writeByte(15)
      ..writeByte(2)
      ..write(obj.sheetList)
      ..writeByte(3)
      ..write(obj.direction)
      ..writeByte(4)
      ..write(obj.size)
      ..writeByte(5)
      ..write(obj.padding)
      ..writeByte(6)
      ..write(obj.mainAxisAlignment)
      ..writeByte(7)
      ..write(obj.crossAxisAlignment)
      ..writeByte(8)
      ..write(obj.widthAdjustment)
      ..writeByte(9)
      ..write(obj.image)
      ..writeByte(10)
      ..write(obj.imageFit)
      ..writeByte(11)
      ..write(obj.color)
      ..writeByte(12)
      ..write(obj.borderColor)
      ..writeByte(13)
      ..write(obj.borderWidth)
      ..writeByte(14)
      ..write(obj.borderRadius)
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
      other is SheetListBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
