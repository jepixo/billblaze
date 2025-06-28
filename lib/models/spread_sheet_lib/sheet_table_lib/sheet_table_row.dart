import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:hive/hive.dart';

part 'sheet_table_row.g.dart';

@HiveType(typeId: 11)
class SheetTableRowBox extends SheetItem {
  @HiveField(3)
  double size;
  @HiveField(4)
  double minSize;
  @HiveField(5)
  double maxSize;
  @HiveField(6)
  bool hide;
  @HiveField(7)
  String rowDecoration;
  
  SheetTableRowBox({
    required super.id, 
    required super.parentId,
    this.size = 20,
    this.minSize = 10,
    this.maxSize = 500,
    this.hide = false,
    this.rowDecoration = '',
    required super.indexPath,
    });
  
  SheetTableRow toSheetTableRow( ) {
    return SheetTableRow(
      id: super.id, 
      parentId: super.parentId,
      size: size,
      maxSize: maxSize,
      minSize: minSize,
      hide: hide,
      rowDecoration: rowDecoration,
      indexPath: indexPath,
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
    this.maxSize = 500,
    this.size = 20,
    this.hide = false,
    this.rowDecoration ='',
    required super.indexPath,
    });

  SheetTableRowBox toSheetTableRowBox( ) {
    return SheetTableRowBox(
      id: super.id, 
      parentId: super.parentId,
      size: size,
      maxSize: maxSize,
      minSize: minSize,
      hide: hide,
      rowDecoration: rowDecoration,
      indexPath: indexPath,
      );
  }
}
