// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';

import 'dart:convert';

import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:billblaze/models/index_path.dart';

part 'sheet_item.g.dart';


@HiveType(typeId: 1)
class SheetItem extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String parentId;
  @HiveField(2)
  IndexPath indexPath;
  

  SheetItem({required this.id, required this.parentId, required this.indexPath});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'parentId': parentId,
      'indexPath': indexPath.toJson(),
    };
    print(map);
    return map;
  }

  factory SheetItem.fromMap(Map<String, dynamic> map) {
    final id = map['id'] ?? '';

    if (id.startsWith('TX-')) {
      return SheetTextBox.fromMap(map);
    } else if (id.startsWith('TB-')) {
      return SheetTableBox.fromMap(map);
    } else if (id.startsWith('LI-')) {
      print('in SheetItemFromMap: '+id);
      return SheetListBox.fromMap(map);
    } else {
      throw Exception('Unknown SheetItem type for id: $id');
    }
  }

  String toJson() => json.encode(toMap());

  factory SheetItem.fromJson(String source) => SheetItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    // TODO: implement toString
    return '${id}, ${parentId}, ${indexPath}, ${runtimeType}';
  }
}
