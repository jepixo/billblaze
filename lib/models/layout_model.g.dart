// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LayoutModelAdapter extends TypeAdapter<LayoutModel> {
  @override
  final int typeId = 4;

  @override
  LayoutModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LayoutModel(
      docPropsList: (fields[0] as List).cast<DocumentPropertiesBox>(),
      spreadSheetList: (fields[1] as List).cast<SheetListBox>(),
      id: fields[2] as String,
      name: fields[3] as String,
      createdAt: fields[4] as DateTime,
      modifiedAt: fields[5] as DateTime,
      pdf: (fields[6] as List?)?.cast<Uint8List>(),
    );
  }

  @override
  void write(BinaryWriter writer, LayoutModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.docPropsList)
      ..writeByte(1)
      ..write(obj.spreadSheetList)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.modifiedAt)
      ..writeByte(6)
      ..write(obj.pdf);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
