// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:fleather/fleather.dart';
// import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hive/hive.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:billblaze/components/elevated_button.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';

part 'text_editor_item.g.dart';

//  ignore: depend_on_referenced_packages
// import 'package:parchment_delta/parchment_delta.dart';
@HiveType(typeId: 3)
class TextEditorItemBox extends SheetItem {
  @HiveField(2)
  final String textEditorController;
  TextEditorItemBox({
    required this.textEditorController,
    required super.id,
    required super.parentId,
  });
}

class TextEditorItem extends SheetItem {
  final QuillController textEditorController;
  final QuillEditorConfigurations textEditorConfigurations;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final QuillSimpleToolbarConfigurations toolBarConfigurations;
  //
  TextEditorItem._({
    required super.id,
    required super.parentId,
    required this.textEditorController,
    required this.textEditorConfigurations,
  })  : focusNode = FocusNode(),
        scrollController = ScrollController(),
        toolBarConfigurations = QuillSimpleToolbarConfigurations(
          controller: textEditorController,
          multiRowsDisplay: false,
        );

  factory TextEditorItem({
    QuillController? textEditorController,
    String? initialValue,
    required String id,
    required String parentId,
    FocusNode? focusNode,
    ScrollController? scrollController,
    QuillSimpleToolbar? toolBarConfigurations,
    QuillEditorConfigurations? textEditorConfigurations,
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

    return TextEditorItem._(
      textEditorController: controller,
      id: id,
      parentId: parentId,
      textEditorConfigurations: configurations,
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

  Widget buildTextEditorToolbar() {
    return QuillToolbar.simple(configurations: toolBarConfigurations);
  }
}

// class TextEditorWidget extends ConsumerStatefulWidget {
//   // final Axis direction;
//   // final int index;
//   final TextEditorItem textEditorItem;
//   final bool isPhantom;
//   // final bool isSheet;
//   final String id;
//   const TextEditorWidget({
//     required this.textEditorItem,
//     required this.isPhantom,
//     required this.id,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _TextEditorWidgetState();
// }

// class _TextEditorWidgetState extends ConsumerState<TextEditorWidget> {
//   late int index;
//   late TextEditorItem textEditorItem;
//   late bool isPhantom;
//   // late Axis direction;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // index = widget.index;
//     textEditorItem = widget.textEditorItem;
//     isPhantom = widget.isPhantom;
//     // direction = Axis.horizontal;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('________TextFIELD BUILD STARTED_________');
//     print(
//         'currentpageINdex in texteditorfield: ${ref.read(currentPageIndexProvider)}');
//     // final currentPageIndex = ref.watch(currentPageIndexProvider);
//     // final textEditorItem = ref.watch(sheetItemProviderFamily(widget.id));
//     // SheetList items = widget.item as SheetList;
//     // int? draggingIndex =
//     //     ref.watch(dragDropProvider.select((p) => p.draggingIndex));
//     // int? potentialDropIndex =
//     //     ref.watch(dragDropProvider.select((p) => p.potentialDropIndex));
//     // SheetList? draggingList =
//     //     ref.watch(dragDropProvider.select((p) => p.draggingItem as SheetList?));
//     // SheetList? potentialList = ref.watch(
//     //     dragDropProvider.select((p) => p.potentialDropItem as SheetList?));
//     // double listWidth = 500 / 2;
//     // double listHeight = 50;
//     // Duration dur = ref.watch(dragDropProvider.select((p) => p.dur));
//     // return PanelWrapper(
//     //     // child: DragWrap(
//     //     //     // phantomChild: QuillEditor(
//     //     //     //     configurations: textEditorItem.textEditorConfigurations,
//     //     //     //     focusNode: textEditorItem.focusNode,
//     //     //     //     scrollController: ScrollController()),
//     //     //     // index: index,
//     //     //     // item: sheetList,
//     //     //     // child: QuillEditor(
//     //     //     //     configurations: textEditorItem.textEditorConfigurations,
//     //     //     //     focusNode: textEditorItem.focusNode,
//     //     //     //     scrollController: textEditorItem.scrollController),
//     //     //     ));
//     //     child: QuillEditor(
//     //   configurations: textEditorItem.textEditorConfigurations,
//     //   focusNode: textEditorItem.focusNode,
//     //   scrollController: textEditorItem.scrollController,
//     // ));
//     if (textEditorItem is TextEditorItem) {
//       return QuillEditor(
//         configurations: textEditorItem.textEditorConfigurations,
//         focusNode: textEditorItem.focusNode,
//         scrollController: textEditorItem.scrollController,
//       );
//     }
//     return SizedBox();
//   }
// }
