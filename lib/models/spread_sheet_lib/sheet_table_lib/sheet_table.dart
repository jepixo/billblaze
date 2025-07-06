import 'dart:convert';

import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_cell.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_column.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_row.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';

part 'sheet_table.g.dart';

@HiveType(typeId: 9)
class SheetTableBox extends SheetItem {
  @HiveField(3)
  List<List<SheetTableCellBox>> cellData;
  @HiveField(4)
  List<SheetTableRowBox> rowData;
  @HiveField(5)
  List<SheetTableColumnBox> columnData;
  @HiveField(6)
  int pinnedRows;
  @HiveField(7)
  int pinnedColumns;
  @HiveField(8)
  SuperDecorationBox sheetTableDecoration;
  @HiveField(9)
  SuperDecorationBox sheetTablebgDecoration;
  @HiveField(10)
  String name;
  @HiveField(11)
  bool expand;

  SheetTableBox({
    required super.id, 
    required super.parentId,
    this.cellData = const [],
    this.rowData = const [],
    this.columnData = const [],
    this.pinnedRows = 1,
    this.pinnedColumns =1,
    required this.sheetTableDecoration,
    SuperDecorationBox? sheetTablebgDecoration,
    required super.indexPath,
    this.name = 'unlabeled',
    this.expand = true,
  }): sheetTablebgDecoration = sheetTablebgDecoration ?? sheetTableDecoration;

  SheetTable toSheetTable(Function findItem, Function textFieldTapDown, bool Function(int index, int length, Object? data) getReplaceTextFunctionForType(int i, QuillController q),) {
    return SheetTable(
      id: super.id, 
      parentId: super.parentId,
      pinnedRows: pinnedRows,
      pinnedColumns: pinnedColumns,
      columnData: columnData.map((e) => e.toSheetTableColumn(),).toList(),
      rowData: rowData.map((e) => e.toSheetTableRow(),).toList(),
      cellData: cellData.map((e) => e.map((e) => e.toSheetTableCell(findItem,textFieldTapDown,getReplaceTextFunctionForType,super.indexPath),).toList(),).toList(),
      sheetTableDecoration: sheetTableDecoration.toSuperDecoration(),
      sheetTablebgDecoration: sheetTablebgDecoration.toSuperDecoration(),
      indexPath: super.indexPath,
      name: name,
      expand:expand,
      );
  }
  
  @override
  Map<String, dynamic> toMap() {
    var map = {
        'type': 'SheetTableBox',
        'id': id,
        'parentId': parentId,
        'indexPath': indexPath.toJson(),
        'cellData': cellData
            .map((row) => row.map((cell) => cell.toMap()).toList())
            .toList(),
        'rowData': rowData.map((r) => r.toMap()).toList(),
        'columnData': columnData.map((c) => c.toMap()).toList(),
        'pinnedRows': pinnedRows,
        'pinnedColumns': pinnedColumns,
        'sheetTableDecoration': sheetTableDecoration.toMap(),
        'sheetTablebgDecoration': sheetTablebgDecoration.toMap(),
        'name': name,
        'expand': expand,
      };
      print('SheetTableBox: '+map.toString());
    return map;
    } 

  factory SheetTableBox.fromMap(Map<String, dynamic> map) => SheetTableBox(
        id: map['id'],
        parentId: map['parentId'],
        indexPath: IndexPath.fromJson(map['indexPath']),
        cellData: (map['cellData'] as List)
            .map((row) => (row as List)
                .map((cell) => SheetTableCellBox.fromMap(cell))
                .toList())
            .toList(),
        rowData: (map['rowData'] as List)
            .map((r) => SheetTableRowBox.fromMap(r))
            .toList(),
        columnData: (map['columnData'] as List)
            .map((c) => SheetTableColumnBox.fromMap(c))
            .toList(),
        pinnedRows: map['pinnedRows'],
        pinnedColumns: map['pinnedColumns'],
        sheetTableDecoration:
            SuperDecorationBox.fromMap(map['sheetTableDecoration']),
        sheetTablebgDecoration:
            SuperDecorationBox.fromMap(map['sheetTablebgDecoration']),
        name: map['name'],
        expand: map['expand'],
      );
  @override
  String toJson() => jsonEncode(toMap());

  factory SheetTableBox.fromJson(String json) =>
    SheetTableBox.fromMap(jsonDecode(json));

  @override
  String toString() {
    // TODO: implement toString
    return '_||SheetTable||_ ${name}, ${id}, ${cellData
            .map((row) => row.map((cell) => cell.toMap()).toList())
            .toList().toString()}---------';
  }
}



class SheetTable extends SheetItem {
  List<List<SheetTableCell>> cellData;
  List<SheetTableRow> rowData;
  List<SheetTableColumn> columnData;
  int pinnedRows;
  int pinnedColumns;
  SuperDecoration sheetTableDecoration;
  SuperDecoration sheetTablebgDecoration;
  String name;
  bool expand;

  SheetTable({
    required super.id,
    required super.parentId,
    this.cellData = const [],
    this.rowData = const [],
    this.columnData = const [],
    this.pinnedRows =1,
    this.pinnedColumns = 1,
    required this.sheetTableDecoration,
    SuperDecoration? sheetTablebgDecoration,
    required super.indexPath,
    this.name ='unlabeled',
    this.expand = true,
  }): sheetTablebgDecoration = sheetTablebgDecoration ?? sheetTableDecoration;

  SheetTableBox toSheetTableBox() {
    return SheetTableBox(
      id: super.id, 
      parentId: super.parentId,
      cellData: cellData.map((e) => e.map((e) => e.toSheetTableCellBox(),).toList(),).toList(),
      rowData: rowData.map((e) => e.toSheetTableRowBox(),).toList(),
      columnData: columnData.map((e) => e.toSheetTableColumnBox(),).toList(),
      pinnedColumns: pinnedColumns,
      pinnedRows: pinnedRows,
      sheetTableDecoration: sheetTableDecoration.toSuperDecorationBox(),
      sheetTablebgDecoration: sheetTablebgDecoration.toSuperDecorationBox(),
      indexPath: super.indexPath,
      name: name,
      expand: expand,
      );
  }

}

