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

class UniStatFunctionAdapter extends TypeAdapter<UniStatFunction> {
  @override
  final int typeId = 17;

  @override
  UniStatFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UniStatFunction(
      inputBlocks: (fields[2] as List).cast<InputBlock>(),
      resultJson: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      func: fields[4] as String,
      formatter: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UniStatFunction obj) {
    writer
      ..writeByte(6)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(3)
      ..write(obj.resultJson)
      ..writeByte(4)
      ..write(obj.func)
      ..writeByte(5)
      ..write(obj.formatter)
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
      other is UniStatFunctionAdapter &&
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
      inputBlocks: (fields[2] as List).cast<InputBlock>(),
      func: fields[3] as String,
      axisLabel: fields[4] as String,
      resultJson: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      lockMode: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ColumnFunction obj) {
    writer
      ..writeByte(7)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(3)
      ..write(obj.func)
      ..writeByte(4)
      ..write(obj.axisLabel)
      ..writeByte(5)
      ..write(obj.resultJson)
      ..writeByte(6)
      ..write(obj.lockMode)
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

class InputBlockFunctionAdapter extends TypeAdapter<InputBlockFunction> {
  @override
  final int typeId = 20;

  @override
  InputBlockFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InputBlockFunction(
      inputBlocks: (fields[2] as List).cast<InputBlock>(),
      label: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InputBlockFunction obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(3)
      ..write(obj.label)
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
      other is InputBlockFunctionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BiStatFunctionAdapter extends TypeAdapter<BiStatFunction> {
  @override
  final int typeId = 21;

  @override
  BiStatFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BiStatFunction(
      inputBlocksX: (fields[2] as List).cast<InputBlock>(),
      inputBlocksY: (fields[3] as List).cast<InputBlock>(),
      resultJson: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      func: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BiStatFunction obj) {
    writer
      ..writeByte(6)
      ..writeByte(2)
      ..write(obj.inputBlocksX)
      ..writeByte(3)
      ..write(obj.inputBlocksY)
      ..writeByte(4)
      ..write(obj.resultJson)
      ..writeByte(5)
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
      other is BiStatFunctionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
