import 'dart:convert';

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
  
  @override
  Map<String, dynamic> toMap() {
    var map =  {
        'type': 'SheetTableRowBox',
        'id': id,
        'parentId': parentId,
        'indexPath': indexPath.toJson(),
        'size': size,
        'minSize': minSize,
        'maxSize': maxSize,
        'hide': hide,
        'rowDecoration': rowDecoration,
      };
      print(map);
    return map;
    }

  factory SheetTableRowBox.fromMap(Map<String, dynamic> map) => SheetTableRowBox(
        id: map['id'],
        parentId: map['parentId'],
        indexPath: IndexPath.fromJson(map['indexPath']),
        size: (map['size'] as num).toDouble(),
        minSize: (map['minSize'] as num).toDouble(),
        maxSize: (map['maxSize'] as num).toDouble(),
        hide: map['hide'],
        rowDecoration: map['rowDecoration'],
      );

  @override
  String toJson() => jsonEncode(toMap());

  factory SheetTableRowBox.fromJson(String json) =>
    SheetTableRowBox.fromMap(jsonDecode(json));

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
