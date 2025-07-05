// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:billblaze/models/bill/bill_type.dart';
import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hive/hive.dart';

import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';

part 'layout_model.g.dart';

@HiveType(typeId: 4)
class LayoutModel extends HiveObject {
  @HiveField(0)
  List<DocumentPropertiesBox> docPropsList;
  @HiveField(1)
  List<SheetListBox> spreadSheetList;
  @HiveField(2)
  String id;
  @HiveField(3)
  String name;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  DateTime modifiedAt;
  @HiveField(6)
  List<Uint8List>? pdf;
  @HiveField(7)
  int type;
  @HiveField(8)
  List<RequiredText> labelList;

  LayoutModel({
    required this.docPropsList,
    required this.spreadSheetList,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.modifiedAt,
    this.type = 0,
    this.pdf = null,
    this.labelList = const [],
  });
  @override
  String toString() {
    // TODO: implement toString
    return '${docPropsList.length}, ${spreadSheetList.length}, ${ id}, ${name}';
  }
}

List<Map<String, dynamic>> extractBIAnalyticsData(Box<LayoutModel> box) {
  Map<String, LayoutModel> finalLayouts = {};

  for (final lm in box.values) {
    if (!lm.id.startsWith('BI')) continue;

    final baseName = lm.name.replaceAll('-revised', '');

    if (lm.name.contains('-revised')) {
      finalLayouts[baseName] = lm;
    } else if (!finalLayouts.containsKey(baseName)) {
      finalLayouts[baseName] = lm;
    }
  }

  List<Map<String, dynamic>> result = [];

  for (final lm in finalLayouts.values) {
    final entry = <String, dynamic>{
      'id': lm.id,
      'name': lm.name,
      'type': SheetType.values[lm.type].name,
      'createdAt': lm.createdAt.toIso8601String(),
      'modifiedAt': lm.modifiedAt.toIso8601String(),
      'createdMonth': '${lm.createdAt.year}-${lm.createdAt.month.toString().padLeft(2, '0')}',
      'createdDate': '${lm.createdAt.year}-${lm.createdAt.month.toString().padLeft(2, '0')}-${lm.createdAt.day.toString().padLeft(2, '0')}',
      'modifiedMonth': '${lm.modifiedAt.year}-${lm.modifiedAt.month.toString().padLeft(2, '0')}',
      'modLagDays': lm.modifiedAt.difference(lm.createdAt).inDays,
      
    };

    for (final rt in lm.labelList) {
      if (rt.name == 'itemSheet') continue;

      final item = getItemAtPath(rt.indexPath, lm.spreadSheetList);
      if (item is! SheetTextBox) continue;

      final raw = Document.fromDelta(Delta.fromJson(item.textEditorController)).toPlainText().trim();
      dynamic parsed;

      switch (SheetTextType.values[rt.sheetTextType]) {
        case SheetTextType.number:
          parsed = double.tryParse(raw);
          break;
        case SheetTextType.integer:
          parsed = int.tryParse(raw);
          break;
        case SheetTextType.bool:
          parsed = raw.toLowerCase() == 'true';
          break;
        case SheetTextType.date:
        case SheetTextType.time:
        case SheetTextType.phone:
        case SheetTextType.string:
        default:
          parsed = raw;
          break;
      }

      entry[rt.name] = parsed;
    }

    result.add(entry);
  }

  return result;
}

SheetItem getItemAtPath(IndexPath indexPath, List<SheetListBox> spreadSheetList) {
    List<int> path = indexPath.toList();
    SheetItem? current;
    // print(indexPath.toString());
    notfound(){
      print('not found '+indexPath.toString());
      return SheetItem(id: 'yo', parentId: '', indexPath: IndexPath(index: -1));
    }
    int i = 0;
    while (i < path.length) {
      int index = path[i];

      if (i == 0) {
        if (index < 0 || index >= spreadSheetList.length) return notfound();
        current = spreadSheetList[index];
        i++;
      } else if (current is SheetListBox) {
        if (index < 0 || index >= current.sheetList.length) return notfound();
        current = current.sheetList[index];
        i++;
      } else if (current is SheetTableBox) {
        if (i + 1 >= path.length) {
          // If there's only one more index, we are selecting the whole table itself
          return current;
        }

        int row = path[i];
        int column = path[i + 1];

        if (row < 0 || row >= current.cellData.length) return notfound();
        if (column < 0 || column >= current.cellData[row].length) return notfound();

        current = current.cellData[row][column].sheetItem;
        i += 2;
      } else {
        return current ?? notfound(); // Hit a leaf like SheetText or similar
      }
    }

    return current ?? notfound();
  }
