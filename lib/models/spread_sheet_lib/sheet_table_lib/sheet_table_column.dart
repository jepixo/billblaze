
import 'dart:convert';

import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:hive/hive.dart';

part 'sheet_table_column.g.dart';

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
  
  @override
  Map<String, dynamic> toMap(){
    var map = {
        'type': 'SheetTableColumnBox',
        'id': id,
        'parentId': parentId,
        'indexPath': indexPath.toJson(),
        'size': size,
        'minSize': minSize,
        'maxSize': maxSize,
        'hide': hide,
        'columnDecoration': columnDecoration,
      };

      print(map);
    return map;
    } 
  factory SheetTableColumnBox.fromMap(Map<String, dynamic> map) => SheetTableColumnBox(
        id: map['id'],
        parentId: map['parentId'],
        indexPath: IndexPath.fromJson(map['indexPath']),
        size: (map['size'] as num).toDouble(),
        minSize: (map['minSize'] as num).toDouble(),
        maxSize: (map['maxSize'] as num).toDouble(),
        hide: map['hide'],
        columnDecoration: map['columnDecoration'],
      );

  @override
  String toJson() => jsonEncode(toMap());

  static SheetTableColumnBox fromJson(String json) =>
      SheetTableColumnBox.fromMap(jsonDecode(json));

}

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
  SheetTableColumn copy() {
    return SheetTableColumn(
      id: id,
      parentId: parentId,
      indexPath: indexPath,
      size: size,
      minSize: minSize,
      maxSize: maxSize,
      hide: hide,
      columnDecoration: columnDecoration,
    );
  }
}
