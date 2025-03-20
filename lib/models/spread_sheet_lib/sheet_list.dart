// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';

import 'package:billblaze/colors.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';

part 'sheet_list.g.dart';

@HiveType(typeId: 2)
class SheetListBox extends SheetItem {
  @HiveField(5)
  List<SheetItem> sheetList;
  @HiveField(6)
  bool direction;
  @HiveField(7)
  List size; 
  @HiveField(8)
  int mainAxisAlignment;
  @HiveField(9)
  int crossAxisAlignment;
  // @HiveField(11)
  // List<double> margin;
  // @HiveField(12)
  // Uint8List? image;
  // @HiveField(13)
  // String imageFit;
  // @HiveField(14)
  // String color;
  // @HiveField(15)
  // String borderColor;
  // @HiveField(16)
  // List<double> borderWidth;
  // @HiveField(17)
  // List<double> borderRadius;

  //constructor
  SheetListBox(
      {required this.sheetList,
      required this.direction,
      required super.id,
      required super.parentId,
      required super.decorationId,
      super.itemDecoration =const [],
      this.size = const [0, 0],
      // this.padding = const [0, 0, 0, 0],
      this.mainAxisAlignment = 0,
      this.crossAxisAlignment = 0,
      // this.image,
      // this.imageFit = 'fitWidth',
      // this.color = '00000000',
      // this.borderColor = '00000000',
      // this.borderRadius = const [0,0,0,0],
      // this.borderWidth = const [0, 0, 0, 0],
      // this.margin = const [0, 0, 0, 0]
      }
      );

  SheetList toSheetList() {
    return SheetList(
        sheetList: sheetList,
        direction: direction == true ? Axis.vertical : Axis.horizontal,
        id: id,
        parentId: parentId,
        crossAxisAlignment: CrossAxisAlignment.values[crossAxisAlignment],
        mainAxisAlignment: MainAxisAlignment.values[mainAxisAlignment],
        itemDecoration: decodeItemDecorationList(itemDecoration),
        size: Size(size[0], size[1]), decorationId: decorationId,
        );
  }
}

class SheetList extends SheetItem {
  List<SheetItem> sheetList;
  Axis direction;
  Size size;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  // ListDecoration listDecoration;

  //contructor
  SheetList( 
      {
      required String id,
      required String parentId,
      List<dynamic> itemDecoration = const [],
      required this.sheetList,
      this.direction = Axis.vertical,
      required String decorationId,
      // this.listDecoration =
      //     const ListDecoration(crossAxisAlignment: CrossAxisAlignment.start),
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.size = const Size(0, 0)})
      : super(id: id, parentId: parentId, itemDecoration: itemDecoration, decorationId: decorationId) {
    // Assign the parentId to each item in the sheetList
    for (var item in sheetList) {
      item.parentId = id;
    }
  }

  SheetListBox toSheetListBox() {
    return SheetListBox(
        sheetList: [],
        direction: direction == Axis.vertical ? true : false,
        id: id,
        parentId: parentId,
        size: [size.width, size.height],
        crossAxisAlignment: crossAxisAlignment.index,
        mainAxisAlignment: mainAxisAlignment.index,
        itemDecoration: encodeItemDecorationList(itemDecoration),
        decorationId: decorationId
        );
  }





  SheetList copyWith({
    List<SheetItem>? sheetList,
    Axis? direction,
    Size? size,
    List<dynamic>? itemDecoration, 
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return SheetList(
      id: super.id,
      parentId: super.parentId,
      sheetList: sheetList ?? this.sheetList,
      direction: direction ?? this.direction,
      size: size ?? this.size,
      itemDecoration: itemDecoration ?? this.itemDecoration,
      mainAxisAlignment: 
      mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: 
      crossAxisAlignment ?? this.crossAxisAlignment, decorationId: super.decorationId,
    );
  }
}

class ListDecoration {
  final EdgeInsets padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets margin;
  final BoxDecoration decoration;

  const ListDecoration({
    this.padding = const EdgeInsets.all(0),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.margin = const EdgeInsets.all(0),
    this.decoration = const BoxDecoration(),
  });

  ListDecoration copyWith({
    EdgeInsets? padding,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    EdgeInsets? margin,
    BoxDecoration? decoration,
  }) {
    return ListDecoration(
      padding: padding ?? this.padding,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
    );
  }
}


EdgeInsets getEdgeInsets(List<double> padding) {
  if (padding.length != 4) {
    throw ArgumentError(
        'Padding list must contain exactly 4 values: [top, right, bottom, left]');
  }
  return EdgeInsets.only(
    top: padding[0],
    right: padding[1],
    bottom: padding[2],
    left: padding[3],
  );
}
 
List<double> getPaddingFromEdgeInsets(EdgeInsets edgeInsets) {
  return [
    edgeInsets.top,
    edgeInsets.right,
    edgeInsets.bottom,
    edgeInsets.left,
  ];
}

Widget buildDecoratedContainer(List<dynamic> itemDecoration, Widget child,bool preview) {
  if (itemDecoration.isEmpty) return child;

  final current = itemDecoration.first;
  // print('dog : '+ current.decoration.color.toString());
  if (current is ItemDecoration) {
    //  print('dog2 : '+ current.decoration.color.toString());
    return Container(
      padding: preview? EdgeInsets.all(1):
      current.padding,
      margin: preview? EdgeInsets.all(1): current.margin,
      alignment: current.alignment,
      decoration: current.decoration,
      foregroundDecoration: current.foregroundDecoration,
      transform: current.transform,
      child: buildDecoratedContainer(
        itemDecoration.sublist(1),
        child,
        false
      ),
    );
  } else if (current is SuperDecoration) {
    // Recursively build containers for SuperDecoration children
    return buildDecoratedContainer(
      [...current.itemDecorationList, ...itemDecoration.sublist(1)],
      child,
      preview
    );
  } else if (current is List) {
    // Handle nested lists recursively
    return buildDecoratedContainer(
      current,
      buildDecoratedContainer(
        itemDecoration.sublist(1),
        child,
        preview
      ),
      preview
    );
  } else {
    throw Exception('Invalid decoration type: ${current.runtimeType}');
  }
}
