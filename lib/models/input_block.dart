// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:billblaze/models/spread_sheet_lib/sheet_functions.dart';
import 'package:hive/hive.dart';

import 'package:billblaze/models/index_path.dart';
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

  InputBlock( {
    required this.indexPath,
    required this.blockIndex,
    required this.id,
    this.function,
    this.isExpanded = false,
  });

  @override
  String toString() {
    // TODO: implement toString
    return '${indexPath.toString()}, ${blockIndex.toString()}, $id, ${function.runtimeType.toString()}, $isExpanded';
  }
}
