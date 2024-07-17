// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_editor_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TextEditorItemAdapter extends TypeAdapter<TextEditorItem> {
  @override
  final int typeId = 3;

  @override
  TextEditorItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextEditorItem(
      textEditorController: fields[2] as QuillController?,
      id: fields[0] as String,
      parentId: fields[1] as String,
      focusNode: fields[4] as FocusNode?,
      scrollController: fields[5] as ScrollController?,
      toolBarConfigurations: fields[6] as QuillSimpleToolbar?,
      textEditorConfigurations: fields[3] as QuillEditorConfigurations?,
    );
  }

  @override
  void write(BinaryWriter writer, TextEditorItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(2)
      ..write(obj.textEditorController)
      ..writeByte(3)
      ..write(obj.textEditorConfigurations)
      ..writeByte(4)
      ..write(obj.focusNode)
      ..writeByte(5)
      ..write(obj.scrollController)
      ..writeByte(6)
      ..write(obj.toolBarConfigurations)
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
      other is TextEditorItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
