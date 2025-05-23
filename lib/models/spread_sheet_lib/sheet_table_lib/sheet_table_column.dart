
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:hive/hive.dart';

part 'sheet_table_column.g.dart';


class SheetTableColumn extends SheetItem {
  double size;
  SheetTableColumn({
    required super.id, 
    required super.parentId,
    this.size = 20,
    });
  SheetTableColumnBox toSheetTableColumnBox( ) {
    return SheetTableColumnBox(
      id: super.id, 
      parentId: super.parentId,
      size: size
      );
  }
}
@HiveType(typeId: 12)
class SheetTableColumnBox extends SheetItem {
  @HiveField(2)
  double size;
  SheetTableColumnBox({
    required super.id, 
    required super.parentId,
    this.size = 20,
    });

  SheetTableColumn toSheetTableColumn( ) {
    return SheetTableColumn(
      id: super.id, 
      parentId: super.parentId,
      size: size
      );
  }

}
