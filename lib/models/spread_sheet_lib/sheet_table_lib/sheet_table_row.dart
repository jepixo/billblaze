import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:hive/hive.dart';

part 'sheet_table_row.g.dart';

@HiveType(typeId: 11)
class SheetTableRowBox extends SheetItem {
  @HiveField(2)
  double size;
  
  SheetTableRowBox({
    required super.id, 
    required super.parentId,
    this.size = 20,
    });
  
  SheetTableRow toSheetTableRow( ) {
    return SheetTableRow(
      id: super.id, 
      parentId: super.parentId,
      size: size
      );
  }
}

class SheetTableRow extends SheetItem {
  double size;
  
  SheetTableRow({
    required super.id, 
    required super.parentId,
    this.size = 20,
    });

  SheetTableRowBox toSheetTableRowBox( ) {
    return SheetTableRowBox(
      id: super.id, 
      parentId: super.parentId,
      size: size
      );
  }
}
