import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:hive/hive.dart';

part 'sheet_table_row.g.dart';

@HiveType(typeId: 11)
class SheetTableRowBox extends SheetItem {
  @HiveField(2)
  double size;
  @HiveField(3)
  double minSize;
  @HiveField(4)
  double maxSize;
  @HiveField(5)
  bool hide;
  @HiveField(6)
  String rowDecoration;
  
  SheetTableRowBox({
    required super.id, 
    required super.parentId,
    this.size = 20,
    this.minSize = 10,
    this.maxSize = 120,
    this.hide = false,
    this.rowDecoration = ''
    });
  
  SheetTableRow toSheetTableRow( ) {
    return SheetTableRow(
      id: super.id, 
      parentId: super.parentId,
      size: size,
      maxSize: maxSize,
      minSize: minSize,
      hide: hide,
      rowDecoration: rowDecoration
      );
  }
}

class SheetTableRow extends SheetItem {
  double size;
  double minSize;
  double maxSize;
  bool hide;
  String rowDecoration;
  
  SheetTableRow({
    required super.id, 
    required super.parentId,
    this.minSize = 10,
    this.maxSize = 120,
    this.size = 20,
    this.hide = false,
    this.rowDecoration ='',
    });

  SheetTableRowBox toSheetTableRowBox( ) {
    return SheetTableRowBox(
      id: super.id, 
      parentId: super.parentId,
      size: size,
      maxSize: maxSize,
      minSize: minSize,
      hide: hide,
      rowDecoration: rowDecoration
      );
  }
}
