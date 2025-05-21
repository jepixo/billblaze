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
      linkedTextEditors: (fields[3] as List?)?.cast<String>(),
      textEditorController: (fields[2] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      id: fields[0] as String,
      parentId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTextBox obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.textEditorController)
      ..writeByte(3)
      ..write(obj.linkedTextEditors)
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
      other is SheetTextBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
