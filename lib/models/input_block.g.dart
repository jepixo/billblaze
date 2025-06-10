// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InputBlockAdapter extends TypeAdapter<InputBlock> {
  @override
  final int typeId = 15;

  @override
  InputBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InputBlock(
      indexPath: fields[0] as IndexPath,
      blockIndex: (fields[1] as List).cast<int>(),
      id: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InputBlock obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.indexPath)
      ..writeByte(1)
      ..write(obj.blockIndex)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
