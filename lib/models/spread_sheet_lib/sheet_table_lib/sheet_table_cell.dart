
import 'package:billblaze/colors.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/models/spread_sheet_lib/spread_sheet.dart';
import 'package:billblaze/screens/layout_designer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'sheet_table_cell.g.dart';

class SheetTableCell extends SheetItem {
  String data;
  SheetItem sheetItem;
  bool isLocked= false;
  bool hasError = false;
  int rowSpan =1;
  int colSpan =1;
  String? ownerId;
  String? errorMessage;
  ValidationRule? validationRule;

  SheetTableCell({
    required super.id, 
    required super.parentId,
    this.data ='',
    required this.sheetItem,
    this.isLocked = false,
    this.hasError = false,
    this.colSpan =1,
    this.rowSpan =1,
    this.errorMessage,
    this.validationRule,
    this.ownerId
    });

  SheetTableCellBox toSheetTableCellBox( ) {
    return SheetTableCellBox(
      id: super.id, 
      parentId: super.parentId,
      sheetItem: boxSheetItem(sheetItem),
      data: data,
      colSpan: colSpan,
      rowSpan: rowSpan,
      hasError: hasError,
      isLocked: isLocked,
      errorMessage: errorMessage,
      ownerId: ownerId,
      validationRule: validationRule?.toValidationRuleBox(),
      );
  }

  SheetItem boxSheetItem(SheetItem sheetItem) {
    if (sheetItem is SheetText) {
      return sheetItem.toTEItemBox(sheetItem);
    }
    else if (sheetItem is SheetList){
      return (sheetItem).toSheetListBox();
    } else if (sheetItem is SheetTable){
      return sheetItem.toSheetTableBox();
    }
    return sheetItem;
  }
  
}


@HiveType(typeId: 10)
class SheetTableCellBox extends SheetItem {
  @HiveField(2)
  String data;
  @HiveField(3)
  SheetItem sheetItem;
  @HiveField(4)
  bool isLocked= false;
  @HiveField(5)
  bool hasError = false;
  @HiveField(6)
  int rowSpan =1;
  @HiveField(7)
  int colSpan =1;
  @HiveField(8)
  String? ownerId;
  @HiveField(9)
  String? errorMessage;
  @HiveField(10)
  ValidationRuleBox? validationRule;

  SheetTableCellBox({
    required super.id, 
    required super.parentId,
    this.data ='',
    required this.sheetItem,
    this.isLocked = false,
    this.hasError = false,
    this.colSpan =1,
    this.rowSpan =1,
    this.errorMessage,
    this.validationRule,
    this.ownerId
    });

  SheetTableCell toSheetTableCell( Function findItem, Function textFieldTapDown ) {
    return SheetTableCell(
      id: super.id, 
      parentId: super.parentId,
      sheetItem: unboxSheetItem(sheetItem,findItem,textFieldTapDown),
      data: data,
      colSpan: colSpan,
      rowSpan: rowSpan,
      hasError: hasError,
      isLocked: isLocked,
      errorMessage: errorMessage,
      ownerId: ownerId,
      validationRule: validationRule?.toValidationRule(),
      );
  }
  
  SheetItem unboxSheetItem(SheetItem sheetItem, Function findItem, Function textFieldTapDown) {
    if (sheetItem is SheetTextBox) {
      return addTextField(
        id: super.id, 
        parentId: super.parentId, 
        findItem: findItem, 
        textFieldTapDown: textFieldTapDown, 
        docString: sheetItem.textEditorController);
    }
    else if (sheetItem is SheetListBox){
      return (sheetItem).toSheetList(findItem,textFieldTapDown);
    } else if (sheetItem is SheetTableBox){
      return sheetItem.toSheetTable(findItem,textFieldTapDown);
    }
    return sheetItem;
  }
  
}

  SheetText addTextField({
    required String id ,
    required String parentId,
    required Function findItem,
    required Function textFieldTapDown,
    required List<Map<String, dynamic>>
        docString, // Use List<Map<String, dynamic>> directly
    List<String> linkedTextFields = const [],
  }) {
    Delta delta;
    print('DocString: $docString');

    try {
      if (docString.isNotEmpty) {
        // Convert List<Map<String, dynamic>> to Delta
        delta = Delta.fromJson(docString);
        // Check if delta is empty or not
        if (delta.isEmpty) {
          delta = Delta(); // Fallback to an empty Delta
        }
      } else {
        delta =
            Delta(); // Default to an empty Delta if docString is null or empty
      }
      print('Decoded Delta: $delta');
    } catch (e) {
      // Handle error if any occurs
      print('Error converting to Delta: $e');
      delta = Delta(); // Default to an empty Delta in case of error
    }

    // Initialize QuillController with the appropriate Document
    QuillController textController;
    if (delta.isEmpty) {
      textController = QuillController(
        document: Document(), // Use an empty document if delta is empty
        selection: const TextSelection.collapsed(offset: 0),
        onSelectionChanged: (textSelection) {
          findItem();
        },
        onDelete: (cursorPosition, forward) {
          findItem();
        },
        onSelectionCompleted: () {
          findItem();
        },
      );
    } else {
      textController = QuillController(
        document: Document.fromDelta(delta), // Use delta to create the document
        selection: const TextSelection.collapsed(offset: 0),
        onSelectionChanged: (textSelection) {
          findItem();
        },
        onDelete: (cursorPosition, forward) {
          findItem();
        },
        onSelectionCompleted: () {
          findItem();
        },
      );
    }

    String newId = id.isEmpty ? const Uuid().v4() : id;
    var textEditorConfigurations = QuillEditorConfigurations(
      enableScribble: true,
      enableSelectionToolbar: true,
      autoFocus: true,
      onTapOutside: (event, focusNode) {
        //     if (!focusNode.hasFocus) {
        //   focusNode.requestFocus();
        // }
      },
      // textSelectionControls: NoMenuTextSelectionControls(),
      contextMenuBuilder: (context, rawEditorState) {
        return Container();
      },
      // padding: EdgeInsets.all(2),
      controller: textController,
      placeholder: '',
      // maxHeight: 50,
      customStyles: DefaultStyles(
        placeHolder: DefaultTextBlockStyle(
          GoogleFonts.lexend(
            color: defaultPalette.extras[0].withOpacity(0.4),
            letterSpacing: -1,
            fontSize:10,
          ),
          VerticalSpacing(0, 0),
          VerticalSpacing(0, 0), null
          )
      ),
      customStyleBuilder: (attribute) {
        return customStyleBuilder(attribute); // Default style
      },
      builder: (context, rawEditor) {
        return textEditorBuilder(rawEditor, newId);
      },
      onTapDown: (details, p1) {
        return textFieldTapDown(details, newId);
      },
    );

    
    return SheetText(
      textEditorController: textController,
      textEditorConfigurations: textEditorConfigurations,
      id: newId,
      parentId:
          parentId,
      linkedTextEditors: linkedTextFields, // Use parentId if not empty
    );
  }

  Widget textEditorBuilder(Widget rawEditor, String newId){
    return Container(
      padding: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
          // border: Border.all(color: defaultPalette.extras[0]),
          color: defaultPalette.primary,
          borderRadius: BorderRadius.circular(2)),
      child: rawEditor,
    );
  }
  