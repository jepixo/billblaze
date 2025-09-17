// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hive_ce/hive.dart';

import 'package:billblaze/models/bill/bill_type.dart';
import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';

// part  'layout_model.g.dart';

// @HiveType(typeId: 4)
class LayoutModel extends HiveObject {
  // @HiveField(0)
  List<DocumentPropertiesBox> docPropsList;
  // @HiveField(1)
  List<SheetListBox> spreadSheetList;
  // @HiveField(2)
  String id;
  // @HiveField(3)
  String name;
  // @HiveField(4)
  DateTime createdAt;
  // @HiveField(5)
  DateTime modifiedAt;
  // @HiveField(6)
  List<Uint8List>? pdf;
  // @HiveField(7)
  int type;
  // @HiveField(8)
  List<RequiredText> labelList;
  // @HiveField(9)
  bool? deleted;
  // @HiveField(10)
  Map<String, SheetDecoration>? sheetDecorationMap;
  
  

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
    this.deleted = false,
    this.sheetDecorationMap = const {},
  });
  // @override
  // String toString() {
  //   // TODO: implement toString
  //   return '${docPropsList.length}, ${spreadSheetList.length}, ${ id}, ${name}';
  // }

  LayoutModel copyWith({
    List<DocumentPropertiesBox>? docPropsList,
    List<SheetListBox>? spreadSheetList,
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<Uint8List>? pdf,
    int? type,
    List<RequiredText>? labelList,
    bool? deleted,
    Map<String, SheetDecoration>? sheetDecorationMap,
  }) {
    return LayoutModel(
      docPropsList: docPropsList ?? this.docPropsList,
      spreadSheetList: spreadSheetList ?? this.spreadSheetList,
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      pdf: pdf ?? this.pdf,
      type: type ?? this.type,
      labelList: labelList ?? this.labelList,
      deleted: deleted ?? this.deleted,
      sheetDecorationMap: sheetDecorationMap ?? this.sheetDecorationMap,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docPropsList': docPropsList.map((x) => x.toMap()).toList(),
      'spreadSheetList': spreadSheetList.map((x) => x.toMap()).toList(),
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'modifiedAt': modifiedAt.millisecondsSinceEpoch,
      'pdf': pdf,
      'type': type,
      'labelList': labelList.map((x) => x.toMap()).toList(),
      'deleted': deleted,
      'sheetDecorationMap': sheetDecorationMap?.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  factory LayoutModel.fromMap(Map<String, dynamic> map) {
    return LayoutModel(
      docPropsList: List<DocumentPropertiesBox>.from((map['docPropsList']).map<DocumentPropertiesBox>((x) => DocumentPropertiesBox.fromMap(x as Map<String,dynamic>),),),
      spreadSheetList: List<SheetListBox>.from((map['spreadSheetList']).map<SheetListBox>((x) => SheetListBox.fromMap(x as Map<String,dynamic>),),),
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(map['modifiedAt'] as int),
      pdf: () {
        final pdfList = map['pdf'];
        if (pdfList is List) {
          return pdfList.map((e) {
            if (e is List) {
              // each element should be List<int>
              return Uint8List.fromList(
                e.map((x) => (x as num).toInt()).toList(),
              );
            }
            throw Exception('Invalid pdf entry: $e');
          }).toList();
        }
        return null;
      }(),

      type: map['type'] as int,
      labelList: List<RequiredText>.from((map['labelList']).map<RequiredText>((x) => RequiredText.fromMap(x as Map<String,dynamic>),),),
      deleted: map['deleted']?? false,
      sheetDecorationMap: (map['sheetDecorationMap'] as Map<String, dynamic>?)
      ?.map((key, value) => MapEntry(
          key,
          SheetDecoration.fromMap(value as Map<String, dynamic>),
        )),
   );
  }

  String toJson() => json.encode(toMap());

  factory LayoutModel.fromJson(String source) => LayoutModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static String toIdFromJson(String source) => (json.decode(source) as Map<String,dynamic>)['id'];

  static Map<String, dynamic> toMetaDataFromJson(String source) { 
    var map =(json.decode(source) as Map<String, dynamic>);
    return {
      'id': map['id'],
      'name': map['name'] as String,
      'createdAt': DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      'modifiedAt': DateTime.fromMillisecondsSinceEpoch(map['modifiedAt'] as int),
      'type': map['type'] as int,
      'deleted': map['deleted'] as bool?
    };
    }

}

SheetItem getItemAtPath(IndexPath indexPath, List<SheetListBox> spreadSheetList) {
    List<int> path = indexPath.toList();
    SheetItem? current;
    // print(indexPath.toString());
    notfound(){
      // print('not found '+indexPath.toString());
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
