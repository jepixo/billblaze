import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';



class SheetTable extends SheetItem {
  List<List<SheetTableCell>> cellData;
  List<SheetTableRow> rowData;
  List<SheetTableColumn> columnData;

  SheetTable({
    required super.id,
    required super.parentId,
    this.cellData = const [],
    this.rowData = const [],
    this.columnData = const [],
  });
}

class SheetTableCell extends SheetItem {
  String data;
  List<Map<String, dynamic>> textControllerJson;

  SheetTableCell({
    required super.id, 
    required super.parentId,
    this.data ='',
    required this.textControllerJson,
    });
  
}

class SheetTableRow extends SheetItem {
  SheetTableRow({required super.id, required super.parentId});
  
}

class SheetTableColumn extends SheetItem {
  SheetTableColumn({required super.id, required super.parentId});

}