// ignore_for_file: public_member_api_docs, sort_constructors_first 
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:flutter/material.dart'; 
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
  int mainAxisAlignment;
  @HiveField(5)
  int crossAxisAlignment;  
  @HiveField(6)
  String decorationId;

  SheetListBox(
      {
      required this.sheetList,
      required this.direction,
      required super.id,
      required super.parentId, 
      this.mainAxisAlignment = 0,
      this.crossAxisAlignment = 0,
      required this.decorationId, 
      });

  SheetList toSheetList() {
    return SheetList(
        sheetList: [],
        direction: direction == true ? Axis.vertical : Axis.horizontal,
        id: id,
        parentId: parentId,
        listDecoration: getSuperDecoration(decorationId),
        );
  }
}

class SheetList extends SheetItem {
  List<SheetItem> sheetList;
  Axis direction;
  Size size;
  SuperDecoration listDecoration;
  MainAxisAlignment mainAxisAlignment;
  CrossAxisAlignment crossAxisAlignment;

  SheetList(
      {required String id,
      required String parentId,
      required this.sheetList,
      this.direction = Axis.vertical,
      required this.listDecoration,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.size = const Size(0, 0)})
      : super(id: id, parentId: parentId) { 
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
        decorationId: listDecoration.id,
        crossAxisAlignment: crossAxisAlignment.index,
        mainAxisAlignment: mainAxisAlignment.index,
         );
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
      MainAxisAlignment? mainAxisAlignment,
      CrossAxisAlignment? crossAxisAlignment,
      SuperDecoration? listDecoration}) {
    return SheetList(
      id: super.id,
      parentId: super.parentId,
      sheetList: sheetList ?? this.sheetList,
      direction: direction ?? this.direction,
      size: size ?? this.size,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      listDecoration: listDecoration ?? this.listDecoration,
    );
  }
}


 