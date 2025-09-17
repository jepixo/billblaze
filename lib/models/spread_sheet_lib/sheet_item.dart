// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:billblaze/colors.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/models/spread_sheet_lib/sized_item.dart';
import 'package:billblaze/screens/layout_designer.dart';

// part  'sheet_item.g.dart';

// @HiveType(typeId: 1)
class SheetItem extends HiveObject {
  // @HiveField(0)
  String id;
  // @HiveField(1)
  String parentId;
  // @HiveField(2)
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
    } else if(id.startsWith('SZ')){
      return SheetSizedItem.fromMap(map);
    } else {
      throw Exception('Unknown SheetItem type for id: $id');
    }
  }

  String toJson() => json.encode(toMap());

  factory SheetItem.fromJson(String source) => SheetItem.fromMap(json.decode(source) as Map<String, dynamic>);

  SheetItem toBox() {
    throw UnimplementedError('$runtimeType Subclasses must override toBox()');
  }

  SheetItem unBox() {
    throw UnimplementedError('$runtimeType Subclasses must override unBox()');
  }

  Widget buildWidget(PanelIndex panelIndex, Map<String, PanelIndex> selectedIndexPaths) {
    return Container(
      margin: const EdgeInsets.only(
        left: 2,
        top: 4,
        right: 2),
      padding: const EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: 0,
          right: 4),
      decoration: BoxDecoration(
        color: defaultPalette.primary,
        border: Border.all(
          strokeAlign:
              BorderSide.strokeAlignInside,
          width:( panelIndex.id ==
                  id || selectedIndexPaths[id]!=null)
              ? 2
              : 1.2,
    
          color:( panelIndex.id ==
                  id || selectedIndexPaths[id]!=null)
              ? defaultPalette.tertiary
              : defaultPalette.black,
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text('SheetItem: $runtimeType'),
    );
  }

  Widget build() {
    return Container(
      margin: const EdgeInsets.only(
        left: 2,
        top: 4,
        right: 2),
      padding: const EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: 0,
          right: 4),
      decoration: BoxDecoration(
        color: defaultPalette.primary,
        border: Border.all(
          strokeAlign:
              BorderSide.strokeAlignInside,
          width: 1.2,
    
          color: defaultPalette.black,
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text('SheetItem: $runtimeType'),
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return '${id}, ${parentId}, ${indexPath}, ${runtimeType}';
  }

  SheetItem copyWith({
    String? id,
    String? parentId,
    IndexPath? indexPath,
  }) {
    return SheetItem(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      indexPath: indexPath ?? this.indexPath,
    );
  }

  String newId() => 'yo';
}
