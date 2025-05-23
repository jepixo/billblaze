// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:fleather/fleather.dart';
// import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hive/hive.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';

part 'sheet_text.g.dart';

//  ignore: depend_on_referenced_packages
// import 'package:parchment_delta/parchment_delta.dart';
@HiveType(typeId: 3)
class SheetTextBox extends SheetItem {
  @HiveField(2)
  final List<Map<String, dynamic>> textEditorController;
  @HiveField(3)
  final List<String>? linkedTextEditors;
  SheetTextBox({
    this.linkedTextEditors = null,
    required this.textEditorController,
    required super.id,
    required super.parentId,
  });

  
}

class SheetText extends SheetItem {
  final QuillController textEditorController;
  final QuillEditorConfigurations textEditorConfigurations;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final QuillSimpleToolbarConfigurations toolBarConfigurations;
  List<String>? linkedTextEditors;
  //
  SheetText._({
    required super.id,
    required super.parentId,
    required this.textEditorController,
    required this.textEditorConfigurations,
    this.linkedTextEditors,
  })  : focusNode = FocusNode(),
        scrollController = ScrollController(),
        toolBarConfigurations = QuillSimpleToolbarConfigurations(
          controller: textEditorController,
          multiRowsDisplay: false,
        ) {}

  factory SheetText({
    QuillController? textEditorController,
    String? initialValue,
    required String id,
    required String parentId,
    FocusNode? focusNode,
    ScrollController? scrollController,
    QuillSimpleToolbar? toolBarConfigurations,
    QuillEditorConfigurations? textEditorConfigurations,
    List<String>? linkedTextEditors,
  }) {
    final controller = textEditorController ??
        QuillController(
          document: initialValue != null
              ? Document.fromDelta(Delta()..insert('$initialValue\n'))
              : Document(),
          selection: const TextSelection.collapsed(offset: 0),
        );

    final configurations = textEditorConfigurations ??
        QuillEditorConfigurations(
          controller: controller,
          padding: EdgeInsets.all(8),
        );

    return SheetText._(
        textEditorController: controller,
        id: id,
        parentId: parentId,
        textEditorConfigurations: configurations,
        linkedTextEditors: linkedTextEditors);
  }

  Delta getTextEditorDocumentAsDelta() {
    return textEditorController.document.toDelta();
  }

  QuillSimpleToolbarConfigurations getToolBarConfig() {
    return toolBarConfigurations;
  }

  List<Map<String, dynamic>> getTextEditorDocumentAsJson() {
    return textEditorController.document.toDelta().toJson();
  }

  SheetText copyWith({
    QuillController? textEditorController,
    QuillEditorConfigurations? textEditorConfigurations,
    FocusNode? focusNode,
    ScrollController? scrollController,
    QuillSimpleToolbarConfigurations? toolBarConfigurations,
    String? id,
    String? parentId,
    List<String>? linkedTextEditors,
  }) {
    return SheetText._(
      textEditorController: textEditorController ?? this.textEditorController,
      textEditorConfigurations:
          textEditorConfigurations ?? this.textEditorConfigurations,
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      linkedTextEditors: linkedTextEditors ?? this.linkedTextEditors,
    );
  }

  SheetTextBox toTEItemBox(SheetText item) {
    print(
        'conversion text: ${item.textEditorController.document.toDelta().toJson()}');
    return SheetTextBox(
        textEditorController:
            textEditorController.document.toDelta().toJson(),
        id: item.id,
        parentId: item.parentId,
        linkedTextEditors: item.linkedTextEditors);
  }
}
