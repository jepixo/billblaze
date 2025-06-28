
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
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
    this.maxSize = 500,
    this.hide = false,
    this.columnDecoration ='',
    required super.indexPath,
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
      indexPath: indexPath,
      );
  }
}
@HiveType(typeId: 12)
class SheetTableColumnBox extends SheetItem {
  @HiveField(3)
  double size;
  @HiveField(4)
  double minSize;
  @HiveField(5)
  double maxSize;
  @HiveField(6)
  bool hide;
  @HiveField(7)
  String columnDecoration;

  SheetTableColumnBox({
    required super.id, 
    required super.parentId,
    this.size = 20,
    this.minSize = 10,
    this.maxSize = 500,
    this.hide = false,
    this.columnDecoration ='',
    required super.indexPath,
    });

  SheetTableColumn toSheetTableColumn( ) {
    return SheetTableColumn(
      id: super.id, 
      parentId: super.parentId,
      size: size,
      maxSize: maxSize,
      minSize: minSize,
      hide: hide,
      columnDecoration: columnDecoration,
      indexPath: indexPath,
      );
  }

}
