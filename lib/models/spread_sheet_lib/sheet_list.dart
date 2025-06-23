// ignore_for_file: public_member_api_docs, sort_constructors_first 
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/providers/box_provider.dart';
import 'package:flutter/material.dart'; 
import 'package:hive/hive.dart';

import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';

part 'sheet_list.g.dart';

@HiveType(typeId: 2)
class SheetListBox extends SheetItem {
  @HiveField(3)
  List<SheetItem> sheetList;
  @HiveField(4)
  bool direction; 
  @HiveField(5)
  int mainAxisAlignment;
  @HiveField(6)
  int crossAxisAlignment;  
  @HiveField(7)
  String decorationId;
  @HiveField(8)
  int mainAxisSize;
  @HiveField(9)
  List<double>? size;

  SheetListBox(
      {
      required this.sheetList,
      required this.direction,
      required super.id,
      required super.parentId, 
      this.mainAxisAlignment = 0,
      this.crossAxisAlignment = 0,
      this.mainAxisSize =0,
      required this.decorationId, 
      required super.indexPath,
      this.size = const [0,0]
      });

  SheetList toSheetList(Function findItem, Function textFieldTapDown) {
    // print('A PARENT: '+ size.toString());
    return SheetList(
        sheetList: unboxSheetList(sheetList,findItem,textFieldTapDown),
        direction: direction == true ? Axis.vertical : Axis.horizontal,
        id: super.id,
        parentId: super.parentId,
        mainAxisAlignment: MainAxisAlignment.values[mainAxisAlignment],
        crossAxisAlignment: CrossAxisAlignment.values[crossAxisAlignment],
        mainAxisSize: MainAxisSize.values[mainAxisSize],
        listDecoration: Boxes.getSuperDecoration(decorationId).toSuperDecoration(),
        indexPath: indexPath,
        size: Size(size?[0]??0, size?[1]??0),
        );
  }

  List<SheetItem> unboxSheetList(List<SheetItem> sheetList, Function findItem, Function textFieldTapDown){
    return sheetList.map((e) {
      if (e is SheetTextBox) {
        return e;
      } else if ( e is SheetListBox) {
        return e.toSheetList(findItem,textFieldTapDown);
      } else if (e is SheetTableBox) {
        return e.toSheetTable(findItem,textFieldTapDown);
      } else {
        return e;
      }
    },).toList();
  }
}

class SheetList extends SheetItem {
  List<SheetItem> sheetList;
  Axis direction;
  Size size;
  SuperDecoration listDecoration;
  MainAxisAlignment mainAxisAlignment;
  CrossAxisAlignment crossAxisAlignment;
  MainAxisSize mainAxisSize;
  SheetList(
      {
      required super.id,
      required super.parentId,
      required super.indexPath,
      required this.sheetList,
      this.direction = Axis.vertical,
      required this.listDecoration,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.mainAxisSize = MainAxisSize.min,
      this.size = const Size(0, 0),
      });

  SheetListBox toSheetListBox() {
    print(size.toString());
    return SheetListBox(
        sheetList: boxSheetList(sheetList),
        direction: direction == Axis.vertical ? true : false,
        id: super.id,
        parentId: super.parentId,
        decorationId: listDecoration.id,
        crossAxisAlignment: crossAxisAlignment.index,
        mainAxisAlignment: mainAxisAlignment.index,
        mainAxisSize: mainAxisSize.index,
        indexPath: indexPath,
        size: [size.width,size.height],
         );
         
  }

  List<SheetItem> boxSheetList(List<SheetItem> sheetList) {
    return sheetList.map((e) {
       if (e is SheetText) {
        return e.toTEItemBox(e);
      } else if (e is SheetList) {
        return e.toSheetListBox();
      } else if (e is SheetTable) {
        return e.toSheetTableBox();
      }
      return e;
    },).toList();
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
      {
      String? parentId,
      String? id,
      List<SheetItem>? sheetList,
      Axis? direction,
      Size? size, 
      MainAxisAlignment? mainAxisAlignment,
      CrossAxisAlignment? crossAxisAlignment,
      MainAxisSize? mainAxisSize,
      SuperDecoration? listDecoration,
      IndexPath? indexPath,
      }) {
    return SheetList(
      id: id?? super.id,
      parentId:parentId?? super.parentId,
      sheetList: sheetList ?? this.sheetList,
      direction: direction ?? this.direction,
      size: size ?? this.size,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      listDecoration: listDecoration ?? this.listDecoration,
      mainAxisSize: mainAxisSize ?? this.mainAxisSize,
      indexPath: indexPath ?? this.indexPath,
    );
  }
}


 