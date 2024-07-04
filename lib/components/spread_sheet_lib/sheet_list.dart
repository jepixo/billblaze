// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:billblaze/components/spread_sheet_lib/text_editor_item.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:billblaze/components/spread_sheet.dart';
import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';

class SheetList extends SheetItem {
  List<SheetItem> sheetList;
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

  @override
  Widget buildWidget(WidgetRef ref, int index, SheetItem item,
      State<StatefulWidget> state, Axis direction) {
    // TODO: implement buildWidget
    return SheetListWidget(
      // sheetList: this,
      direction: direction,
      index: index,
      // item: item,
      // state: state,
      isPhantom: false, id: this.id,
    );
  }

  @override
  Widget buildPhantom({Axis? direction, SheetList? item}) {
    // TODO: implement buildPhantom
    return SheetListWidget(
      // sheetList: this,
      direction: direction ?? Axis.vertical,
      index: 0,
      // item: item ?? SheetList(id: '', parentId: '', sheetList: []),
      isPhantom: true,
      id: this.id,
    );
  }

  // Widget buildSheet(WidgetRef ref, int index, SheetItem item,
  //     State<StatefulWidget> state, Axis direction) {
  //   return SheetListWidget(
  //     sheetList: this,
  //     index: index,
  //     item: item,
  //     isPhantom: false,
  //     isSheet: true,
  //   );
  // }
}

class SheetListNotifier extends StateNotifier<SheetList> {
  SheetListNotifier(SheetList state) : super(state);
  // Adding an item to the list
  void add(SheetItem item) {
    state.add(item);
    state = SheetList(
        id: state.id,
        parentId: state.parentId,
        direction: state.direction,
        sheetList: List.from(state.sheetList));
  }

  // Removing an item from the list
  bool remove(SheetItem item) {
    bool result = state.remove(item);
    state = SheetList(
        id: state.id,
        parentId: state.parentId,
        direction: state.direction,
        sheetList: List.from(state.sheetList));
    return result;
  }

  // Removing an item by index
  SheetItem removeAt(int index) {
    SheetItem result = state.removeAt(index);
    state = SheetList(
        id: state.id,
        parentId: state.parentId,
        direction: state.direction,
        sheetList: List.from(state.sheetList));
    return result;
  }

  // Setting an item by index
  void set(int index, SheetItem item) {
    state[index] = item;
    state = SheetList(
        id: state.id,
        parentId: state.parentId,
        direction: state.direction,
        sheetList: List.from(state.sheetList));
  }

  // Clearing the list
  void clear() {
    state.clear();
    state = SheetList(id: state.id, parentId: state.parentId, sheetList: []);
  }

  // Inserting an item at a specific index
  void insert(int index, SheetItem item) {
    state.insert(index, item);
    state = SheetList(
        id: state.id,
        parentId: state.parentId,
        direction: state.direction,
        sheetList: List.from(state.sheetList));
  }

  // Inserting multiple items at a specific index
  void insertAll(int index, Iterable<SheetItem> items) {
    state.insertAll(index, items);
    state = SheetList(
        id: state.id,
        parentId: state.parentId,
        direction: state.direction,
        sheetList: List.from(state.sheetList));
  }

  // Adding multiple items to the list
  void addAll(Iterable<SheetItem> items) {
    state.addAll(items);
    state = SheetList(
        id: state.id,
        parentId: state.parentId,
        direction: state.direction,
        sheetList: List.from(state.sheetList));
  }

  // Finding the first item that matches the given condition
  SheetItem firstWhere(bool Function(SheetItem item) test,
      {SheetItem Function()? orElse}) {
    return state.firstWhere(test, orElse: orElse);
  }

  void updateParentId(String parentId) {
    state.parentId = parentId;
  }

  void updateDirection(Axis direction) {
    state.direction = direction;
  }
}

//
//
class SheetListWidget extends ConsumerStatefulWidget {
  // final SheetList sheetList;
  final Axis direction;
  final Widget Function(BuildContext context, WidgetRef ref)? footerBuilder;
  final Widget Function(BuildContext context, WidgetRef ref)? headerBuilder;
  final int index;
  // final SheetItem item;
  final bool isPhantom;
  // final State? state;
  final String id;
  // final double height;
  const SheetListWidget({
    super.key,
    this.direction = Axis.vertical,
    this.footerBuilder,
    this.headerBuilder,
    required this.index,
    required this.isPhantom,
    required this.id,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SheetListWidgetState();
}

class _SheetListWidgetState extends ConsumerState<SheetListWidget> {
  late Axis direction;
  late SheetList sheetList;
  late Widget Function(BuildContext context, WidgetRef ref) headerBuilder;
  late Widget Function(BuildContext context, WidgetRef ref) footerBuilder;
  final double listHeight = 300;
  final double listWidth = 200;

  late int index;
  late SheetList item;
  late State state;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    direction = widget.direction;
    // sheetList = widget.sheetList;
    headerBuilder = widget.headerBuilder ?? _defaultHeaderBuilder;
    footerBuilder = widget.footerBuilder ?? _defaultFooterBuilder;
    index = widget.index;
    // item = widget.item as SheetList;
    // state = widget.state ?? this;
  }

  Widget _defaultHeaderBuilder(BuildContext context, WidgetRef ref) {
    return Container(
      height: listHeight * 0.11,
      width: listWidth,
      padding: EdgeInsets.only(left: 5),
      child: Row(
        children: [Text('data')],
      ),
    );
  }

  Widget _defaultFooterBuilder(BuildContext context, WidgetRef ref) {
    return Container(
      height: listHeight * 0.11,
      width: listWidth,
      padding: EdgeInsets.only(left: 5),
      child: Row(
        children: [Text('data')],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  // @override
  // Widget build(BuildContext context) {
  //   final currentPageIndex = ref.watch(currentPageIndexProvider);
  //   final TextEditorItem textEditorItem =
  //       ref.watch(sheetItemProviderFamily(widget.id)) as TextEditorItem;

  //   final sheetList =
  //       ref.watch(sheetListProviderFamily(textEditorItem.parentId));
  //   SheetList items = item as SheetList;
  //   int draggingIndex =
  //       ref.watch(dragDropProvider.select((p) => p.draggingIndex));
  //   int potentialDropIndex =
  //       ref.watch(dragDropProvider.select((p) => p.potentialDropIndex));
  //   SheetList? draggingList =
  //       ref.watch(dragDropProvider.select((p) => p.draggingList as SheetList?));
  //   SheetList? potentialList = ref.watch(
  //       dragDropProvider.select((p) => p.potentialDropList as SheetList?));
  //   // double listWidth = direction == Axis.horizontal ? 500 / 7 : 500 / 2;
  //   // double listHeight = 50;
  //   final double sWidth = MediaQuery.of(context).size.width;
  //   final double sHeight = MediaQuery.of(context).size.height;
  //   Duration dur = ref.watch(dragDropProvider.select((p) => p.dur));
  //   // if (widget.isSheet) {
  //   //   return Container(
  //   //     height: sHeight,
  //   //     width: sWidth,
  //   //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
  //   //     padding: EdgeInsets.all(listHeight * 0.015),
  //   //     child: SingleChildScrollView(
  //   //       child: Column(
  //   //         mainAxisAlignment: MainAxisAlignment.center,
  //   //         children: [
  //   //           // headerBuilder(context, ref),
  //   //           Container(
  //   //             height: sHeight,
  //   //             width: sWidth,
  //   //             padding: EdgeInsets.all(listHeight * 0.015),
  //   //             decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
  //   //             child: ListView.builder(
  //   //               itemCount: sheetList.length,
  //   //               scrollDirection: direction,
  //   //               itemBuilder: (BuildContext context, int i) {
  //   //                 return sheetList[i]
  //   //                     .buildWidget(ref, i, item, state, direction);
  //   //               },
  //   //             ),
  //   //           ),
  //   //           // footerBuilder(context, ref),
  //   //         ],
  //   //       ),
  //   //     ),
  //   //   );
  //   // }
  //   if (!widget.isPhantom) {
  //     return Center();
  //   } else {
  //     return Container(
  //       height: listHeight,
  //       width: listWidth,
  //       decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
  //       padding: EdgeInsets.all(listHeight * 0.015),
  //       child: SingleChildScrollView(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             headerBuilder(context, ref),
  //             Container(
  //               height: listHeight * 0.75,
  //               width: listWidth * 0.95,
  //               padding: EdgeInsets.all(listHeight * 0.015),
  //               decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
  //               child: ListView.builder(
  //                 itemCount: sheetList.length,
  //                 scrollDirection: direction,
  //                 itemBuilder: (BuildContext context, int i) {
  //                   // return sheetList[i].buildPhantom();
  //                 },
  //               ),
  //             ),
  //             footerBuilder(context, ref),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }
}
