// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:fleather/fleather.dart';
// import 'dart:math';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hive/hive.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';

part 'sheet_text.g.dart';

//  ignore: depend_on_referenced_packages
// import 'package:parchment_delta/parchment_delta.dart';
@HiveType(typeId: 3)
class SheetTextBox extends SheetItem {
  @HiveField(3)
  final List<Map<String, dynamic>> textEditorController;
  @HiveField(4)
  final SuperDecorationBox textDecoration;
  @HiveField(5)
  String name;
  @HiveField(6)
  bool hide;
  @HiveField(7)
  List<(IndexPath, List<int>)> inputBlocks;

  SheetTextBox({
    required this.textDecoration,
    required this.textEditorController,
    required super.id,
    required super.parentId,
    required this.hide,
    required this.name,
    required super.indexPath,
    List<(IndexPath, List<int>)>? inputBlocks,
  }): inputBlocks = inputBlocks ?? [(indexPath, [-2])];

  
}

class SheetText extends SheetItem {
  final QuillController textEditorController;
  final QuillEditorConfigurations textEditorConfigurations;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final QuillSimpleToolbarConfigurations toolBarConfigurations;
  String name;
  bool hide;
  SuperDecoration textDecoration;
  List<(IndexPath, List<int>)> inputBlocks;

  //
  SheetText._({
    required super.id,
    required super.parentId,
    required this.textEditorController,
    required this.textEditorConfigurations,
    required this.textDecoration,
    required this.name,
    required this.hide,
    required super.indexPath,
    required this.inputBlocks,
  })  : focusNode = FocusNode(),
        scrollController = ScrollController(),
        toolBarConfigurations = QuillSimpleToolbarConfigurations(
          controller: textEditorController,
          multiRowsDisplay: false,
        );

  factory SheetText({
    QuillController? textEditorController,
    String? initialValue,
    required String id,
    required String parentId,
    FocusNode? focusNode,
    ScrollController? scrollController,
    QuillSimpleToolbar? toolBarConfigurations,
    QuillEditorConfigurations? textEditorConfigurations,
    required SuperDecoration textDecoration,
    required String name,
    required bool hide,
    required IndexPath indexPath,
    List<(IndexPath, List<int>)>? inputBlocks,
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
        textDecoration: textDecoration,
        hide: hide,
        name: name,
        indexPath: indexPath,
        inputBlocks: inputBlocks ?? [(indexPath, [-2])],
        );
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
    SuperDecoration? textDecoration,
    String? name,
    bool? hide,
    IndexPath? indexPath,
    List<(IndexPath, List<int>)>? inputBlocks,
  }) {
    return SheetText._(
      textEditorController: textEditorController ?? this.textEditorController,
      textEditorConfigurations:
          textEditorConfigurations ?? this.textEditorConfigurations,
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      textDecoration: textDecoration ?? this.textDecoration,
      hide: hide??this.hide,
      name: name??this.name,
      indexPath: indexPath?? this.indexPath,
      inputBlocks: inputBlocks ?? this.inputBlocks,
    );
  }

  SheetTextBox toTEItemBox(SheetText item) {
    // print(
    //     'conversion text: ${item.textEditorController.document.toDelta().toJson()}');
    return SheetTextBox(
        textEditorController:
            textEditorController.document.toDelta().toJson(),
        id: item.id,
        parentId: item.parentId,
        hide: hide,
        name: name,
        indexPath: indexPath,
        textDecoration: item.textDecoration.toSuperDecorationBox(),
        inputBlocks: item.inputBlocks,
        );
  }
}
