// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_functions.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetFunctionAdapter extends TypeAdapter<SheetFunction> {
  @override
  final int typeId = 16;

  @override
  SheetFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetFunction(
      fields[0] as int,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetFunction obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.returnType)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetFunctionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SumFunctionAdapter extends TypeAdapter<SumFunction> {
  @override
  final int typeId = 17;

  @override
  SumFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SumFunction(
      (fields[2] as List).cast<InputBlock>(),
    );
  }

  @override
  void write(BinaryWriter writer, SumFunction obj) {
    writer
      ..writeByte(3)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(0)
      ..write(obj.returnType)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SumFunctionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ColumnFunctionAdapter extends TypeAdapter<ColumnFunction> {
  @override
  final int typeId = 19;

  @override
  ColumnFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ColumnFunction(
      (fields[2] as List).cast<InputBlock>(),
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ColumnFunction obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(3)
      ..write(obj.func)
      ..writeByte(0)
      ..write(obj.returnType)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnFunctionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
