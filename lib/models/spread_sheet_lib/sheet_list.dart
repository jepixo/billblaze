// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
part 'sheet_list.g.dart';

@HiveType(typeId: 2)
class SheetList extends SheetItem {
  @HiveField(2)
  List<SheetItem> sheetList;
  @HiveField(3)
  Axis direction;
  SheetList({
    required String id,
    required String parentId,
    required this.sheetList,
    this.direction = Axis.vertical,
  }) : super(id: id, parentId: parentId) {
    // Assign the parentId to each item in the sheetList
    for (var item in sheetList) {
      item.parentId = id;
    }
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

  // Checking if the list contains a specific item
  bool contains(SheetItem item) {
    return sheetList.contains(item);
  }

  // Finding the index of a specific item
  int indexOf(SheetItem item) {
    return sheetList.indexOf(item);
  }

  // Sorting the list
  void sort([int Function(SheetItem a, SheetItem b)? compare]) {
    sheetList.sort(compare);
  }

  // Shuffling the list
  void shuffle([Random? random]) {
    sheetList.shuffle(random);
  }

  // Reversing the list
  Iterable<SheetItem> get reversed {
    return sheetList.reversed;
  }

  // Getting a sublist
  List<SheetItem> sublist(int start, [int? end]) {
    return sheetList.sublist(start, end);
  }

  // Getting a list iterator
  Iterator<SheetItem> get iterator {
    return sheetList.iterator;
  }

  // Finding the first item that matches the given condition
  SheetItem firstWhere(bool Function(SheetItem item) test,
      {SheetItem Function()? orElse}) {
    return sheetList.firstWhere(test, orElse: orElse);
  }
}
