// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index_path.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IndexPathAdapter extends TypeAdapter<IndexPath> {
  @override
  final int typeId = 14;

  @override
  IndexPath read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IndexPath(
      index: fields[1] as int,
      parent: fields[0] as IndexPath?,
    );
  }

  @override
  void write(BinaryWriter writer, IndexPath obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.parent)
      ..writeByte(1)
      ..write(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexPathAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
