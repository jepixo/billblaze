// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:billblaze/models/index_path.dart';

part 'sheet_item.g.dart';

var parentId = Uuid().v4();

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
    return <String, dynamic>{
      'id': id,
      'parentId': parentId,
      'indexPath': indexPath.toJson(),
    };
  }

  factory SheetItem.fromMap(Map<String, dynamic> map) {
    return SheetItem(
      id: map['id'] as String,
      parentId: map['parentId'] as String,
      indexPath: IndexPath.fromJson(map['indexPath'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory SheetItem.fromJson(String source) => SheetItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
