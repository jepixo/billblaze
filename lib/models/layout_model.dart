// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  LayoutModel({
    required this.docPropsList,
    required this.spreadSheetList,
    required this.id,
  });
}
