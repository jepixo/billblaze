// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:hive/hive.dart';

import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';

part 'layout_model.g.dart';

@HiveType(typeId: 4)
class LayoutModel extends HiveObject {
  @HiveField(0)
  List<DocumentPropertiesBox> docPropsList;
  @HiveField(1)
  List<SheetListBox> spreadSheetList;
  @HiveField(2)
  String id;
  @HiveField(3)
  String name;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  DateTime modifiedAt;
  @HiveField(6)
  List<Uint8List>? pdf;

  LayoutModel({
    required this.docPropsList,
    required this.spreadSheetList,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.modifiedAt,
    this.pdf = null,
  });
}
