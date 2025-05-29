
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:hive/hive.dart';

part 'sheet_table_column.g.dart';


class SheetTableColumn extends SheetItem {
  double size;
  double minSize;
  double maxSize;
  bool hide;
  String columnDecoration;

  SheetTableColumn({
    required super.id, 
    required super.parentId,
    this.size = 20,
    this.minSize = 10,
    this.maxSize = 120,
    this.hide = false,
    this.columnDecoration ='',
    });
  SheetTableColumnBox toSheetTableColumnBox( ) {
    return SheetTableColumnBox(
      id: super.id, 
      parentId: super.parentId,
      size: size,
      hide: hide,
      maxSize: maxSize,
      minSize: minSize,
      columnDecoration:columnDecoration,

      );
  }
}
@HiveType(typeId: 12)
class SheetTableColumnBox extends SheetItem {
  @HiveField(2)
  double size;
  @HiveField(3)
  double minSize;
  @HiveField(4)
  double maxSize;
  @HiveField(5)
  bool hide;
  @HiveField(6)
  String columnDecoration;

  SheetTableColumnBox({
    required super.id, 
    required super.parentId,
    this.size = 20,
    this.minSize = 10,
    this.maxSize = 120,
    this.hide = false,
    this.columnDecoration ='',
    });

  SheetTableColumn toSheetTableColumn( ) {
    return SheetTableColumn(
      id: super.id, 
      parentId: super.parentId,
      size: size,
      maxSize: maxSize,
      minSize: minSize,
      hide: hide,
      columnDecoration: columnDecoration
      );
  }

}
