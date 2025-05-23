import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_cell.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_column.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table_row.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:hive/hive.dart';

part 'sheet_table.g.dart';

@HiveType(typeId: 9)
class SheetTableBox extends SheetItem {
  @HiveField(2)
  List<List<SheetTableCellBox>> cellData;
  @HiveField(3)
  List<SheetTableRowBox> rowData;
  @HiveField(4)
  List<SheetTableColumnBox> columnData;
  @HiveField(5)
  int pinnedRows;
  @HiveField(6)
  int pinnedColumns;

  SheetTableBox({
    required super.id, 
    required super.parentId,
    this.cellData = const [],
    this.rowData = const [],
    this.columnData = const [],
    this.pinnedRows = 1,
    this.pinnedColumns =1,
    
  });

  SheetTable toSheetTable(Function findItem, Function textFieldTapDown) {
    return SheetTable(
      id: super.id, 
      parentId: super.parentId,
      pinnedRows: pinnedRows,
      pinnedColumns: pinnedColumns,
      columnData: columnData.map((e) => e.toSheetTableColumn(),).toList(),
      rowData: rowData.map((e) => e.toSheetTableRow(),).toList(),
      cellData: cellData.map((e) => e.map((e) => e.toSheetTableCell(findItem,textFieldTapDown),).toList(),).toList()
      );
  }
  

}



class SheetTable extends SheetItem {
  List<List<SheetTableCell>> cellData;
  List<SheetTableRow> rowData;
  List<SheetTableColumn> columnData;
  int pinnedRows;
  int pinnedColumns;

  SheetTable({
    required super.id,
    required super.parentId,
    this.cellData = const [],
    this.rowData = const [],
    this.columnData = const [],
    this.pinnedRows =1,
    this.pinnedColumns = 1,
  });

  SheetTableBox toSheetTableBox() {
    return SheetTableBox(
      id: super.id, 
      parentId: super.parentId,
      cellData: cellData.map((e) => e.map((e) => e.toSheetTableCellBox(),).toList(),).toList(),
      rowData: rowData.map((e) => e.toSheetTableRowBox(),).toList(),
      columnData: columnData.map((e) => e.toSheetTableColumnBox(),).toList(),
      pinnedColumns: pinnedColumns,
      pinnedRows: pinnedRows,
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
