// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_functions.dart';

part 'input_block.g.dart';

@HiveType(typeId: 15)
class InputBlock {
  @HiveField(0)
  IndexPath indexPath;
  @HiveField(1)
  List<int> blockIndex;
  @HiveField(2)
  String id;
  @HiveField(3)
  bool isExpanded;
  @HiveField(4)
  SheetFunction? function;
  @HiveField(5)
  bool useConst;

  InputBlock( {
    required this.indexPath,
    required this.blockIndex,
    required this.id,
    this.function,
    this.isExpanded = false,
    this.useConst = true,
  });

  @override
  String toString() {
    // TODO: implement toString
    return '|${indexPath.toString()}, ${blockIndex.toString()}, $id, ${function.runtimeType.toString()}, $isExpanded, $useConst |';
  }
  Map<String, dynamic> toMap() {
    var map = {
        'indexPath': indexPath.toJson(),
        'blockIndex': blockIndex,
        'id': id,
        'isExpanded': isExpanded,
        'function': function?.toMap(), // null-safe
        'useConst': useConst
      };
      print(map);
    return map;
    }

  factory InputBlock.fromMap(Map<String, dynamic> map) {
    return InputBlock(
      indexPath: map['indexPath'] != null
          ? IndexPath.fromJson(map['indexPath'])
          : IndexPath(index: -6),
      blockIndex: map['blockIndex'] != null
          ? List<int>.from(map['blockIndex'])
          : [],
      id: map['id'] ?? '',
      isExpanded: map['isExpanded'] ?? false,
      function: map['function'] != null
          ? SheetFunction.fromMap(map['function'])
          : null,
      useConst: map['useConst'],
    );
  }


  String toJson() => jsonEncode(toMap());
  factory InputBlock.fromJson(String json) =>
      InputBlock.fromMap(jsonDecode(json));

  InputBlock copyWith({
    IndexPath? indexPath,
    List<int>? blockIndex,
    String? id,
    bool? isExpanded,
    SheetFunction? function,
    bool? useConst,
  }) {
    return InputBlock(
      indexPath:indexPath ?? this.indexPath,
      blockIndex :blockIndex ?? this.blockIndex,
      id:id ?? this.id,
      isExpanded:isExpanded ?? this.isExpanded,
      function:function ?? this.function,
      useConst:useConst ?? this.useConst,
    );
  }
}
