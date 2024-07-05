// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';
import 'package:billblaze/components/spread_sheet_lib/drag_drop_state.dart';
import 'package:billblaze/components/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/components/spread_sheet_lib/text_editor_item.dart';
import 'package:billblaze/models/document_properties_model.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// import 'package:billblaze/components/spread_sheet_lib/text_editor_widget.dart';
var parentId = Uuid().v4();

abstract class SheetItem {
  final String id;
  String parentId;

  SheetItem({required this.id, required this.parentId});
}
