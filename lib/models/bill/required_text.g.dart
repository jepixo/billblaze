// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'required_text.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequiredTextAdapter extends TypeAdapter<RequiredText> {
  @override
  final int typeId = 18;

  @override
  RequiredText read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequiredText(
      name: fields[0] as String,
      sheetTextType: fields[1] as int,
      indexPath: fields[2] as IndexPath,
      isOptional: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RequiredText obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sheetTextType)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.isOptional);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequiredTextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
