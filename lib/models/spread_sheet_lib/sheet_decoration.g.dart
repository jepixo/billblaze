// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_decoration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetDecorationAdapter extends TypeAdapter<SheetDecoration> {
  @override
  final int typeId = 6;

  @override
  SheetDecoration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetDecoration(
      id: fields[0] as String,
      name: fields[1] as String,
      access: fields[2] as Access,
    );
  }

  @override
  void write(BinaryWriter writer, SheetDecoration obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.access);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetDecorationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SuperDecorationBoxAdapter extends TypeAdapter<SuperDecorationBox> {
  @override
  final int typeId = 7;

  @override
  SuperDecorationBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SuperDecorationBox(
      id: fields[0] as String,
      name: fields[1] as String,
      itemDecorationList: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SuperDecorationBox obj) {
    writer
      ..writeByte(4)
      ..writeByte(3)
      ..write(obj.itemDecorationList)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.access);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperDecorationBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemDecorationBoxAdapter extends TypeAdapter<ItemDecorationBox> {
  @override
  final int typeId = 8;

  @override
  ItemDecorationBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemDecorationBox(
      itemDecoration: (fields[3] as Map).cast<String, dynamic>(),
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemDecorationBox obj) {
    writer
      ..writeByte(4)
      ..writeByte(3)
      ..write(obj.itemDecoration)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.access);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemDecorationBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccessAdapter extends TypeAdapter<Access> {
  @override
  final int typeId = 5;

  @override
  Access read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Access.local;
      case 1:
        return Access.global;
      default:
        return Access.local;
    }
  }

  @override
  void write(BinaryWriter writer, Access obj) {
    switch (obj) {
      case Access.local:
        writer.writeByte(0);
        break;
      case Access.global:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
