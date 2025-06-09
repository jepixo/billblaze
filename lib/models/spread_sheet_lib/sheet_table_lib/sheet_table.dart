import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_cell.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_column.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_row.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
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
  }): sheetTablebgDecoration = sheetTablebgDecoration ?? sheetTableDecoration;

  SheetTable toSheetTable(Function findItem, Function textFieldTapDown) {
    return SheetTable(
      id: super.id, 
      parentId: super.parentId,
      pinnedRows: pinnedRows,
      pinnedColumns: pinnedColumns,
      columnData: columnData.map((e) => e.toSheetTableColumn(),).toList(),
      rowData: rowData.map((e) => e.toSheetTableRow(),).toList(),
      cellData: cellData.map((e) => e.map((e) => e.toSheetTableCell(findItem,textFieldTapDown),).toList(),).toList(),
      sheetTableDecoration: sheetTableDecoration.toSuperDecoration(),
      sheetTablebgDecoration: sheetTablebgDecoration.toSuperDecoration(),
      indexPath: indexPath,
      name: name,
      );
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
      indexPath: indexPath,
      name: name,
      );
  }

}


enum ValidationType {
  number,
  text,
  dropdown,
  regex,
  date,
  email,
  custom,
}

class ValidationRule {
  final ValidationType type;
  final bool required;
  final String? regexPattern;
  final List<String>? allowedValues; // for dropdowns
  final String? customMessage;
  final String? customFunction; // for API or DSL rule definitions

  ValidationRule({
    required this.type,
    this.required = false,
    this.regexPattern,
    this.allowedValues,
    this.customMessage,
    this.customFunction,
  });

  ValidationRuleBox toValidationRuleBox(){
    return ValidationRuleBox(
      type: type.index,
      required: required,
      regexPattern: regexPattern,
      allowedValues: allowedValues,
      customMessage: customMessage,
      customFunction: customFunction 
      );
  }
}

@HiveType(typeId: 13)
class ValidationRuleBox {
  @HiveField(0)
  final int type;
  @HiveField(1)
  final bool required;
  @HiveField(2)
  final String? regexPattern;
  @HiveField(3)
  final List<String>? allowedValues; // for dropdowns
  @HiveField(4)
  final String? customMessage;
  @HiveField(5)
  final String? customFunction; // for API or DSL rule definitions

  ValidationRuleBox({
    required this.type,
    this.required = false,
    this.regexPattern,
    this.allowedValues,
    this.customMessage,
    this.customFunction,
  });

  ValidationRule toValidationRule() {
    return ValidationRule(
      type:ValidationType.values[type],
      required: required,
      regexPattern: regexPattern,
      allowedValues: allowedValues,
      customMessage: customMessage,
      customFunction: customFunction 
    );
  }
}
