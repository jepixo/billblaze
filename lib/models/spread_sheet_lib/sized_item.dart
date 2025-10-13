// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:billblaze/colors.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:uuid/uuid.dart';

// part  'sized_item.g.dart';

// @HiveType(typeId: 23)
class SheetSizedItem extends SheetItem {
  // @HiveField(3)
  double width;
  // @HiveField(4)
  double height;
  // @HiveField(5)
  String sizedItemDecoration;
  // @HiveField(6)
  bool hide;
  SheetSizedItem({
    required super.id, 
    required super.parentId,
    required super.indexPath,
    required this.width,
    required this.height,
    required this.hide,
    required this.sizedItemDecoration,
    });
  
  @override
  SheetSizedItem toBox() {
    return this;
  }

  @override
  SheetSizedItem unBox() {
    return this;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': 'SheetSizedItem',
      'id': id,
      'parentId': parentId,
      'indexPath': indexPath.toJson(),
      'width': width,
      'height': height,
      'sizedItemDecoration': sizedItemDecoration,
      'hide': hide,
    };
  }

  factory SheetSizedItem.fromMap(Map<String, dynamic> map) {
    return SheetSizedItem(
      id: map['id'],
      parentId: map['parentId'],
      indexPath: IndexPath.fromJson(map['indexPath']),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      sizedItemDecoration: map['sizedItemDecoration'] as String,
      hide: map['hide'] as bool, 
    );
  }

  String toJson() => json.encode(toMap());

  factory SheetSizedItem.fromJson(String source) => SheetSizedItem.fromMap(json.decode(source) as Map<String, dynamic>);

  void toggleVisibility(){
    hide = !hide;
  }

  void updateWidth(double value){
    width = value;
  }

  void updateHeight(double value){
    height = value;
  }

  void assignDecorationId(String id){
    sizedItemDecoration = id;
  }

  @override
  Widget buildWidget(PanelIndex panelIndex, Map<String, PanelIndex> selectedIndexPaths, {
    Function? buildDecoratedContainer,
    Map? sheetDecorationMap,
  }){
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(
        left: 2,
        top: 4,
        right: 2),
      decoration: BoxDecoration(
        color: defaultPalette.primary,
        border: Border.all(
          strokeAlign:
              BorderSide.strokeAlignInside,
          width:( panelIndex.id ==
                  super.id || selectedIndexPaths[super.id]!=null)
              ? 2
              : 1.2,
          color:( panelIndex.id == super.id || selectedIndexPaths[super.id]!=null)
              ? defaultPalette.tertiary
              : defaultPalette.black,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: buildDecoratedContainer!(sheetDecorationMap![sizedItemDecoration], const SizedBox(), false),
      ),
    );
  }
  @override
  Widget build() {
    // TODO: implement build
    return SizedBox(
      height: height,
      width: width,
    );
  }

  
  @override
  String newId() {
    // TODO: implement newId
    return 'SZ-${Uuid().v4()}';
  }

  @override
  SheetSizedItem copyWith({
    String? id,
    String? parentId,
    IndexPath? indexPath,
    double? width,
    double? height,
    String? sizedItemDecoration,
    bool? hide,
  }) {
    return SheetSizedItem(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      indexPath: indexPath ?? this.indexPath,
      width: width ?? this.width,
      height: height ?? this.height,
      sizedItemDecoration: sizedItemDecoration ?? this.sizedItemDecoration,
      hide: hide ?? this.hide,
    );
  }
}
