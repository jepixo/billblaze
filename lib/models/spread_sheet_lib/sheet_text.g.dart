// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_text.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetTextBoxAdapter extends TypeAdapter<SheetTextBox> {
  @override
  final int typeId = 3;

  @override
  SheetTextBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTextBox(
      textDecoration: fields[4] as SuperDecorationBox,
      textEditorController: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      id: fields[0] as String,
      parentId: fields[1] as String,
      hide: fields[6] as bool,
      name: fields[5] as String,
      indexPath: fields[2] as IndexPath,
      inputBlocks: (fields[7] as List?)?.cast<InputBlock>(),
      type: fields[8] as int,
      locked: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTextBox obj) {
    writer
      ..writeByte(10)
      ..writeByte(3)
      ..write(obj.textEditorController)
      ..writeByte(4)
      ..write(obj.textDecoration)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.hide)
      ..writeByte(7)
      ..write(obj.inputBlocks)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.locked)
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
      other is SheetTextBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
