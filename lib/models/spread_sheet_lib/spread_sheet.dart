// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'spread_sheet.g.dart';

var parentId = Uuid().v4();

@HiveType(typeId: 1)
class SheetItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String parentId;

  SheetItem({required this.id, required this.parentId});
}
