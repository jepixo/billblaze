// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'dart:typed_data';

import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';

import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';

part 'sheet_list.g.dart';

@HiveType(typeId: 2)
class SheetListBox extends SheetItem {
  @HiveField(2)
  List<SheetItem> sheetList;
  @HiveField(3)
  bool direction;
  @HiveField(4)
  List size;
  @HiveField(5)
  List<double> padding;
  @HiveField(6)
  String mainAxisAlignment;
  @HiveField(7)
  String crossAxisAlignment;
  @HiveField(8)
  List<double> widthAdjustment;
  @HiveField(9)
  Uint8List? image;
  @HiveField(10)
  String imageFit;
  @HiveField(11)
  String color;
  @HiveField(12)
  String borderColor;
  @HiveField(13)
  List<double> borderWidth;
  @HiveField(14)
  List<double> borderRadius;

  SheetListBox(
      {required this.sheetList,
      required this.direction,
      required super.id,
      required super.parentId,
      this.size = const [0, 0],
      this.padding = const [0, 0, 0, 0],
      this.mainAxisAlignment = 'start',
      this.crossAxisAlignment = 'start',
      this.image,
      this.imageFit = 'fitWidth',
      this.color = '00000000',
      this.borderColor = '00000000',
      this.borderRadius = const [0,0,0,0],
      this.borderWidth = const [0, 0, 0, 0],
      this.widthAdjustment = const [0, 0, 0, 0]});

  SheetList toSheetList() {
    return SheetList(
        sheetList: sheetList,
        direction: direction == true ? Axis.vertical : Axis.horizontal,
        id: id,
        parentId: parentId,
        size: Size(size[0], size[1]),
        listDecoration: ListDecoration(
          padding: getEdgeInsets(padding),
          crossAxisAlignment: crossAxisAlignment == 'end'
              ? CrossAxisAlignment.end
              : crossAxisAlignment == 'center'
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
          mainAxisAlignment: getMainAxisAlignment(mainAxisAlignment),
          decoration: BoxDecoration(
              color: hexToColor(color),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius[0]),
                topRight: Radius.circular(borderRadius[1]),
                bottomLeft: Radius.circular(borderRadius[2]),
                bottomRight: Radius.circular(borderRadius[3]),
              ),
              border: Border(
                  top: BorderSide(
                      color: defaultPalette.transparent, width: borderWidth[0]),
                  bottom: BorderSide(
                      color: hexToColor(borderColor), width: borderWidth[1]),
                  left: BorderSide(
                      color: defaultPalette.transparent, width: borderWidth[2]),
                  right: BorderSide(
                      color: defaultPalette.transparent,
                      width: borderWidth[3])),
              image: image == null
                  ? null
                  : DecorationImage(
                      image: MemoryImage(image!), fit: getBoxFit(imageFit))),
          widthAdjustment: getEdgeInsets(widthAdjustment),
        ));
  }
}

class SheetList extends SheetItem {
  List<SheetItem> sheetList;
  Axis direction;
  Size size;
  ListDecoration listDecoration;

  SheetList(
      {required String id,
      required String parentId,
      required this.sheetList,
      this.direction = Axis.vertical,
      this.listDecoration =
          const ListDecoration(crossAxisAlignment: CrossAxisAlignment.start),
      this.size = const Size(0, 0)})
      : super(id: id, parentId: parentId) {
    // Assign the parentId to each item in the sheetList
    for (var item in sheetList) {
      item.parentId = id;
    }
  }

  SheetListBox toSheetListBox() {
    return SheetListBox(
        sheetList: sheetList,
        direction: direction == Axis.vertical ? true : false,
        id: id,
        parentId: parentId,
        size: [size.width, size.height]);
  }

  // Adding an item to the list
  void add(SheetItem item) {
    item.parentId = this.id;
    sheetList.add(item);
  }

  // Removing an item from the list
  bool remove(SheetItem item) {
    return sheetList.remove(item);
  }

  // Removing an item by index
  SheetItem removeAt(int index) {
    return sheetList.removeAt(index);
  }

  // Getting an item by index
  SheetItem operator [](int index) {
    return sheetList[index];
  }

  // Setting an item by index
  void operator []=(int index, SheetItem item) {
    item.parentId = this.id;
    sheetList[index] = item;
  }

  // Getting the length of the list
  int get length {
    return sheetList.length;
  }

  // Checking if the list is empty
  bool get isEmpty {
    return sheetList.isEmpty;
  }

  // Checking if the list is not empty
  bool get isNotEmpty {
    return sheetList.isNotEmpty;
  }

  // Clearing the list
  void clear() {
    sheetList.clear();
  }

  // Inserting an item at a specific index
  void insert(int index, SheetItem item) {
    item.parentId = this.id;
    sheetList.insert(index, item);
  }

  // Inserting multiple items at a specific index
  void insertAll(int index, Iterable<SheetItem> items) {
    for (var item in items) {
      item.parentId = this.id;
    }
    sheetList.insertAll(index, items);
  }

  // Adding multiple items to the list
  void addAll(Iterable<SheetItem> items) {
    for (var item in items) {
      item.parentId = this.id;
    }
    sheetList.addAll(items);
  }

  // Finding the index of a specific item
  int indexOf(SheetItem item) {
    return sheetList.indexOf(item);
  }

  SheetList copyWith(
      {List<SheetItem>? sheetList,
      Axis? direction,
      Size? size,
      ListDecoration? listDecoration}) {
    return SheetList(
      id: super.id,
      parentId: super.parentId,
      sheetList: sheetList ?? this.sheetList,
      direction: direction ?? this.direction,
      size: size ?? this.size,
      listDecoration: listDecoration ?? this.listDecoration,
    );
  }
}

class ListDecoration {
  final EdgeInsets padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets widthAdjustment;
  final BoxDecoration decoration;

  const ListDecoration({
    this.padding = const EdgeInsets.all(0),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.widthAdjustment = const EdgeInsets.all(0),
    this.decoration = const BoxDecoration(),
  });

  ListDecoration copyWith({
    EdgeInsets? padding,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    EdgeInsets? widthAdjustment,
    BoxDecoration? decoration,
  }) {
    return ListDecoration(
      padding: padding ?? this.padding,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      widthAdjustment: widthAdjustment ?? this.widthAdjustment,
      decoration: decoration ?? this.decoration,
    );
  }
}

MainAxisAlignment getMainAxisAlignment(String? mainAxisAlignment) {
  switch (mainAxisAlignment) {
    case 'end':
      return MainAxisAlignment.end;
    case 'center':
      return MainAxisAlignment.center;
    case 'spaceBetween':
      return MainAxisAlignment.spaceBetween;
    case 'spaceEvenly':
      return MainAxisAlignment.spaceEvenly;
    case 'spaceAround':
      return MainAxisAlignment.spaceAround;
    default:
      return MainAxisAlignment.start;
  }
}

CrossAxisAlignment getCrossAxisAlignment(String? crossAxisAlignment) {
  switch (crossAxisAlignment) {
    case 'end':
      return CrossAxisAlignment.end;
    case 'center':
      return CrossAxisAlignment.center;
    case 'stretch':
      return CrossAxisAlignment.stretch;
    case 'baseline':
      return CrossAxisAlignment.baseline;
    default:
      return CrossAxisAlignment.start; // Default value
  }
}

BoxFit getBoxFit(String? boxFit) {
  switch (boxFit) {
    case 'fill':
      return BoxFit.fill;
    case 'contain':
      return BoxFit.contain;
    case 'cover':
      return BoxFit.cover;
    case 'fitWidth':
      return BoxFit.fitWidth;
    case 'fitHeight':
      return BoxFit.fitHeight;
    case 'none':
      return BoxFit.none;
    case 'scaleDown':
      return BoxFit.scaleDown;
    default:
      return BoxFit.cover; // Default value
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

String getStringFromMainAxisAlignment(MainAxisAlignment alignment) {
  switch (alignment) {
    case MainAxisAlignment.end:
      return 'end';
    case MainAxisAlignment.center:
      return 'center';
    case MainAxisAlignment.spaceBetween:
      return 'spaceBetween';
    case MainAxisAlignment.spaceEvenly:
      return 'spaceEvenly';
    case MainAxisAlignment.spaceAround:
      return 'spaceAround';
    default:
      return 'start';
  }
}

String getStringFromCrossAxisAlignment(CrossAxisAlignment alignment) {
  switch (alignment) {
    case CrossAxisAlignment.end:
      return 'end';
    case CrossAxisAlignment.center:
      return 'center';
    case CrossAxisAlignment.stretch:
      return 'stretch';
    case CrossAxisAlignment.baseline:
      return 'baseline';
    default:
      return 'start'; // Default value
  }
}

String getStringFromBoxFit(BoxFit? boxFit) {
  if (boxFit == null) {
    return 'fitWidth';
  }
  switch (boxFit) {
    case BoxFit.fill:
      return 'fill';
    case BoxFit.contain:
      return 'contain';
    case BoxFit.cover:
      return 'cover';
    case BoxFit.fitWidth:
      return 'fitWidth';
    case BoxFit.fitHeight:
      return 'fitHeight';
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scaleDown';
    default:
      return 'cover'; // Default value
  }
}

List<double> getPaddingFromEdgeInsets(EdgeInsets edgeInsets) {
  return [
    edgeInsets.top,
    edgeInsets.right,
    edgeInsets.bottom,
    edgeInsets.left,
  ];
}
