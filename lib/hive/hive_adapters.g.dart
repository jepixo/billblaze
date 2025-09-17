// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class DocumentPropertiesBoxAdapter extends TypeAdapter<DocumentPropertiesBox> {
  @override
  final typeId = 0;

  @override
  DocumentPropertiesBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentPropertiesBox(
      pageNumberController: fields[0] as String,
      marginAllController: fields[1] as String,
      marginLeftController: fields[2] as String,
      marginRightController: fields[3] as String,
      marginBottomController: fields[4] as String,
      marginTopController: fields[5] as String,
      orientationController: fields[6] as bool,
      pageFormatController: (fields[7] as Map).cast<String, double>(),
      useIndividualMargins: fields[8] == null ? false : fields[8] as bool,
      pageColor: fields[9] == null ? "FFFFFF" : fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentPropertiesBox obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.pageNumberController)
      ..writeByte(1)
      ..write(obj.marginAllController)
      ..writeByte(2)
      ..write(obj.marginLeftController)
      ..writeByte(3)
      ..write(obj.marginRightController)
      ..writeByte(4)
      ..write(obj.marginBottomController)
      ..writeByte(5)
      ..write(obj.marginTopController)
      ..writeByte(6)
      ..write(obj.orientationController)
      ..writeByte(7)
      ..write(obj.pageFormatController)
      ..writeByte(8)
      ..write(obj.useIndividualMargins)
      ..writeByte(9)
      ..write(obj.pageColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentPropertiesBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SheetItemAdapter extends TypeAdapter<SheetItem> {
  @override
  final typeId = 1;

  @override
  SheetItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetItem(
      id: fields[0] as String,
      parentId: fields[1] as String,
      indexPath: fields[2] as IndexPath,
    );
  }

  @override
  void write(BinaryWriter writer, SheetItem obj) {
    writer
      ..writeByte(3)
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
      other is SheetItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SheetListBoxAdapter extends TypeAdapter<SheetListBox> {
  @override
  final typeId = 2;

  @override
  SheetListBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetListBox(
      sheetList: (fields[3] as List).cast<SheetItem>(),
      direction: fields[4] as bool,
      id: fields[0] as String,
      parentId: fields[1] as String,
      mainAxisAlignment: fields[5] == null ? 0 : (fields[5] as num).toInt(),
      crossAxisAlignment: fields[6] == null ? 0 : (fields[6] as num).toInt(),
      mainAxisSize: fields[8] == null ? 0 : (fields[8] as num).toInt(),
      decorationId: fields[7] as String,
      indexPath: fields[2] as IndexPath,
      size: fields[9] == null
          ? const [0, 0]
          : (fields[9] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SheetListBox obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.sheetList)
      ..writeByte(4)
      ..write(obj.direction)
      ..writeByte(5)
      ..write(obj.mainAxisAlignment)
      ..writeByte(6)
      ..write(obj.crossAxisAlignment)
      ..writeByte(7)
      ..write(obj.decorationId)
      ..writeByte(8)
      ..write(obj.mainAxisSize)
      ..writeByte(9)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetListBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SheetTextBoxAdapter extends TypeAdapter<SheetTextBox> {
  @override
  final typeId = 3;

  @override
  SheetTextBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTextBox(
      textDecoration: fields[4] as SuperDecorationBox,
      id: fields[0] as String,
      parentId: fields[1] as String,
      hide: fields[6] as bool,
      name: fields[5] as String,
      indexPath: fields[2] as IndexPath,
      inputBlocks: (fields[7] as List?)?.cast<InputBlock>(),
      type: fields[8] == null ? 0 : (fields[8] as num).toInt(),
      locked: fields[9] as bool,
      textEditorControllerString: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SheetTextBox obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.textEditorControllerString)
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
      ..write(obj.locked);
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

class LayoutModelAdapter extends TypeAdapter<LayoutModel> {
  @override
  final typeId = 4;

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
      type: fields[7] == null ? 0 : (fields[7] as num).toInt(),
      pdf: fields[6] == null ? null : (fields[6] as List?)?.cast<Uint8List>(),
      labelList: fields[8] == null
          ? const []
          : (fields[8] as List).cast<RequiredText>(),
      deleted: fields[9] == null ? false : fields[9] as bool?,
      sheetDecorationMap: fields[10] == null
          ? const {}
          : (fields[10] as Map?)?.cast<String, SheetDecoration>(),
    );
  }

  @override
  void write(BinaryWriter writer, LayoutModel obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.pdf)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.labelList)
      ..writeByte(9)
      ..write(obj.deleted)
      ..writeByte(10)
      ..write(obj.sheetDecorationMap);
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

class SheetDecorationAdapter extends TypeAdapter<SheetDecoration> {
  @override
  final typeId = 6;

  @override
  SheetDecoration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetDecoration(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetDecoration obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
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
  final typeId = 7;

  @override
  SuperDecorationBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SuperDecorationBox(
      id: fields[0] as String,
      name: fields[1] == null ? 'Untitled' : fields[1] as String,
      itemDecorationList:
          fields[3] == null ? const [] : (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SuperDecorationBox obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.itemDecorationList);
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
  final typeId = 8;

  @override
  ItemDecorationBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemDecorationBox(
      id: fields[0] as String,
      name: fields[1] == null ? 'Untitled' : fields[1] as String,
      itemDecorationString: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemDecorationBox obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.itemDecorationString);
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

class SheetTableBoxAdapter extends TypeAdapter<SheetTableBox> {
  @override
  final typeId = 9;

  @override
  SheetTableBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      cellData: fields[3] == null
          ? const []
          : (fields[3] as List)
              .map((e) => (e as List).cast<SheetTableCellBox>())
              .toList(),
      rowData: fields[4] == null
          ? const []
          : (fields[4] as List).cast<SheetTableRowBox>(),
      columnData: fields[5] == null
          ? const []
          : (fields[5] as List).cast<SheetTableColumnBox>(),
      pinnedRows: fields[6] == null ? 1 : (fields[6] as num).toInt(),
      pinnedColumns: fields[7] == null ? 1 : (fields[7] as num).toInt(),
      sheetTableDecoration: fields[8] as SuperDecorationBox,
      sheetTablebgDecoration: fields[9] as SuperDecorationBox?,
      indexPath: fields[2] as IndexPath,
      name: fields[10] == null ? 'unlabeled' : fields[10] as String,
      expand: fields[11] == null ? true : fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableBox obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.cellData)
      ..writeByte(4)
      ..write(obj.rowData)
      ..writeByte(5)
      ..write(obj.columnData)
      ..writeByte(6)
      ..write(obj.pinnedRows)
      ..writeByte(7)
      ..write(obj.pinnedColumns)
      ..writeByte(8)
      ..write(obj.sheetTableDecoration)
      ..writeByte(9)
      ..write(obj.sheetTablebgDecoration)
      ..writeByte(10)
      ..write(obj.name)
      ..writeByte(11)
      ..write(obj.expand);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetTableBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SheetTableCellBoxAdapter extends TypeAdapter<SheetTableCellBox> {
  @override
  final typeId = 10;

  @override
  SheetTableCellBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableCellBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      data: fields[3] == null ? '' : fields[3] as String,
      sheetItem: fields[4] as SheetItem,
      isVisible: fields[5] == null ? true : fields[5] as bool,
      hasError: fields[6] == null ? false : fields[6] as bool,
      colSpan: fields[8] == null ? 1 : (fields[8] as num).toInt(),
      rowSpan: fields[7] == null ? 1 : (fields[7] as num).toInt(),
      indexPath: fields[2] as IndexPath,
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableCellBox obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.sheetItem)
      ..writeByte(5)
      ..write(obj.isVisible)
      ..writeByte(6)
      ..write(obj.hasError)
      ..writeByte(7)
      ..write(obj.rowSpan)
      ..writeByte(8)
      ..write(obj.colSpan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetTableCellBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SheetTableRowBoxAdapter extends TypeAdapter<SheetTableRowBox> {
  @override
  final typeId = 11;

  @override
  SheetTableRowBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableRowBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      size: fields[3] == null ? 20 : (fields[3] as num).toDouble(),
      minSize: fields[4] == null ? 10 : (fields[4] as num).toDouble(),
      maxSize: fields[5] == null ? 500 : (fields[5] as num).toDouble(),
      hide: fields[6] == null ? false : fields[6] as bool,
      rowDecoration: fields[7] == null ? '' : fields[7] as String,
      indexPath: fields[2] as IndexPath,
      rowInputBlocks: (fields[8] as List).cast<InputBlock>(),
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableRowBox obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.minSize)
      ..writeByte(5)
      ..write(obj.maxSize)
      ..writeByte(6)
      ..write(obj.hide)
      ..writeByte(7)
      ..write(obj.rowDecoration)
      ..writeByte(8)
      ..write(obj.rowInputBlocks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetTableRowBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SheetTableColumnBoxAdapter extends TypeAdapter<SheetTableColumnBox> {
  @override
  final typeId = 12;

  @override
  SheetTableColumnBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetTableColumnBox(
      id: fields[0] as String,
      parentId: fields[1] as String,
      size: fields[3] == null ? 20 : (fields[3] as num).toDouble(),
      minSize: fields[4] == null ? 10 : (fields[4] as num).toDouble(),
      maxSize: fields[5] == null ? 500 : (fields[5] as num).toDouble(),
      hide: fields[6] == null ? false : fields[6] as bool,
      columnDecoration: fields[7] == null ? '' : fields[7] as String,
      indexPath: fields[2] as IndexPath,
      columnInputBlocks: (fields[8] as List).cast<InputBlock>(),
    );
  }

  @override
  void write(BinaryWriter writer, SheetTableColumnBox obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.minSize)
      ..writeByte(5)
      ..write(obj.maxSize)
      ..writeByte(6)
      ..write(obj.hide)
      ..writeByte(7)
      ..write(obj.columnDecoration)
      ..writeByte(8)
      ..write(obj.columnInputBlocks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetTableColumnBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IndexPathAdapter extends TypeAdapter<IndexPath> {
  @override
  final typeId = 14;

  @override
  IndexPath read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IndexPath(
      index: (fields[1] as num).toInt(),
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

class InputBlockAdapter extends TypeAdapter<InputBlock> {
  @override
  final typeId = 15;

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
      function: fields[4] as SheetFunction?,
      isExpanded: fields[3] == null ? false : fields[3] as bool,
      useConst: fields[5] == null ? true : fields[5] as bool,
      lockMode: fields[6] == null ? 0 : (fields[6] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, InputBlock obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.indexPath)
      ..writeByte(1)
      ..write(obj.blockIndex)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.isExpanded)
      ..writeByte(4)
      ..write(obj.function)
      ..writeByte(5)
      ..write(obj.useConst)
      ..writeByte(6)
      ..write(obj.lockMode);
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

class SheetFunctionAdapter extends TypeAdapter<SheetFunction> {
  @override
  final typeId = 16;

  @override
  SheetFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetFunction(
      (fields[0] as num).toInt(),
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
  final typeId = 17;

  @override
  UniStatFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UniStatFunction(
      inputBlocks: (fields[2] as List).cast<InputBlock>(),
      func: fields[4] as String,
      formatterString: fields[5] as String?,
      resultJsonString: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UniStatFunction obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(3)
      ..write(obj.resultJsonString)
      ..writeByte(4)
      ..write(obj.func)
      ..writeByte(5)
      ..write(obj.formatterString);
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

class RequiredTextAdapter extends TypeAdapter<RequiredText> {
  @override
  final typeId = 18;

  @override
  RequiredText read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequiredText(
      name: fields[0] as String,
      sheetTextType: (fields[1] as num).toInt(),
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

class ColumnFunctionAdapter extends TypeAdapter<ColumnFunction> {
  @override
  final typeId = 19;

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
      lockMode: fields[6] == null ? false : fields[6] as bool,
      resultJsonString: (fields[5] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ColumnFunction obj) {
    writer
      ..writeByte(5)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(3)
      ..write(obj.func)
      ..writeByte(4)
      ..write(obj.axisLabel)
      ..writeByte(5)
      ..write(obj.resultJsonString)
      ..writeByte(6)
      ..write(obj.lockMode);
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
  final typeId = 20;

  @override
  InputBlockFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InputBlockFunction(
      inputBlocks: (fields[2] as List).cast<InputBlock>(),
      label: fields[3] as String,
      resultJsonString: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, InputBlockFunction obj) {
    writer
      ..writeByte(3)
      ..writeByte(2)
      ..write(obj.inputBlocks)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.resultJsonString);
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
  final typeId = 21;

  @override
  BiStatFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BiStatFunction(
      inputBlocksX: (fields[2] as List).cast<InputBlock>(),
      inputBlocksY: (fields[3] as List).cast<InputBlock>(),
      func: fields[5] as String,
      isX: fields[6] == null ? true : fields[6] as bool,
      resultJsonString: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BiStatFunction obj) {
    writer
      ..writeByte(5)
      ..writeByte(2)
      ..write(obj.inputBlocksX)
      ..writeByte(3)
      ..write(obj.inputBlocksY)
      ..writeByte(4)
      ..write(obj.resultJsonString)
      ..writeByte(5)
      ..write(obj.func)
      ..writeByte(6)
      ..write(obj.isX);
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

class UidGeneratorFunctionAdapter extends TypeAdapter<UidGeneratorFunction> {
  @override
  final typeId = 22;

  @override
  UidGeneratorFunction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UidGeneratorFunction(
      template: fields[2] as String,
      idKey: fields[4] == null ? '00' : fields[4] as String,
      func: fields[5] == null ? 'uidGenerator' : fields[5] as String,
      dateTime: fields[6] as DateTime?,
      resultJsonString: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UidGeneratorFunction obj) {
    writer
      ..writeByte(5)
      ..writeByte(2)
      ..write(obj.template)
      ..writeByte(3)
      ..write(obj.resultJsonString)
      ..writeByte(4)
      ..write(obj.idKey)
      ..writeByte(5)
      ..write(obj.func)
      ..writeByte(6)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UidGeneratorFunctionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SheetSizedItemAdapter extends TypeAdapter<SheetSizedItem> {
  @override
  final typeId = 23;

  @override
  SheetSizedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetSizedItem(
      id: fields[0] as String,
      parentId: fields[1] as String,
      indexPath: fields[2] as IndexPath,
      width: (fields[3] as num).toDouble(),
      height: (fields[4] as num).toDouble(),
      hide: fields[6] as bool,
      sizedItemDecoration: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SheetSizedItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.indexPath)
      ..writeByte(3)
      ..write(obj.width)
      ..writeByte(4)
      ..write(obj.height)
      ..writeByte(5)
      ..write(obj.sizedItemDecoration)
      ..writeByte(6)
      ..write(obj.hide);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetSizedItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
