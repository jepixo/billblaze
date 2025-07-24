// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:billblaze/colors.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_table_lib/sheet_table.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/screens/layout_designer.dart';

part 'sheet_table_cell.g.dart';

class SheetTableCell extends SheetItem {
  String data;
  SheetItem sheetItem;
  bool isVisible= true;
  bool hasError = false;
  int rowSpan =1;
  int colSpan =1;
  String? ownerId;
  String? errorMessage;

  SheetTableCell({
    required super.id, 
    required super.parentId,
    this.data ='',
    required this.sheetItem,
    this.isVisible = true,
    this.hasError = false,
    this.colSpan =1,
    this.rowSpan =1,
    this.errorMessage,
    this.ownerId,
    required super.indexPath,
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
      isVisible: isVisible,
      indexPath: indexPath,
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
  @HiveField(3)
  String data;
  @HiveField(4)
  SheetItem sheetItem;
  @HiveField(5)
  bool isVisible= true;
  @HiveField(6)
  bool hasError = false;
  @HiveField(7)
  int rowSpan = 1;
  @HiveField(8)
  int colSpan = 1;

  SheetTableCellBox({
    required super.id, 
    required super.parentId,
    this.data ='',
    required this.sheetItem,
    this.isVisible = true,
    this.hasError = false,
    this.colSpan =1,
    this.rowSpan =1,
    required super.indexPath,
    });

  SheetTableCell toSheetTableCell( Function findItem, Function textFieldTapDown, bool Function(int index, int length, Object? data) getReplaceTextFunctionForType(int i, QuillController q),IndexPath sheetTableIndexPath ) {
    super.indexPath.parent = sheetTableIndexPath;
    // print('toTableCELL : ${super.id}');
    return SheetTableCell(
      id: super.id, 
      parentId: super.parentId,
      sheetItem: unboxSheetItem(sheetItem,findItem,textFieldTapDown,getReplaceTextFunctionForType,super.indexPath),
      data: data,
      colSpan: colSpan,
      rowSpan: rowSpan,
      hasError: hasError,
      isVisible: isVisible,
      indexPath: super.indexPath,
    );
  }
  
  SheetItem unboxSheetItem(SheetItem sheetItem, Function findItem, Function textFieldTapDown, bool Function(int index, int length, Object? data) getReplaceTextFunctionForType(int i, QuillController q), IndexPath sheetTableCellIndexPath) {
    sheetItem.indexPath.parent = sheetTableCellIndexPath;
    if (sheetItem is SheetTextBox) {
      // print('name: ${sheetItem.name}, and locked: ${sheetItem.locked}, parent: ${sheetItem.parentId.substring(0,2)}');
      return addTextField(
        id: sheetItem.id,
        parentId: sheetItem.parentId,
        findItem: findItem, 
        textFieldTapDown: textFieldTapDown, 
        getReplaceTextFunctionForType: getReplaceTextFunctionForType,
        docString: sheetItem.textEditorController,
        textDecoration: sheetItem.textDecoration.toSuperDecoration(),
        hide: sheetItem.hide,
        name: sheetItem.name,
        indexPath: sheetItem.indexPath,
        inputBlocks: sheetItem.inputBlocks,
        type: SheetTextType.values[sheetItem.type],
        locked: sheetItem.locked,
      );
    }
    else if (sheetItem is SheetListBox){
      return (sheetItem).toSheetList(findItem,textFieldTapDown,getReplaceTextFunctionForType);
    } else if (sheetItem is SheetTableBox){
      return sheetItem.toSheetTable(findItem,textFieldTapDown,getReplaceTextFunctionForType);
    }
    return sheetItem;
    }

  @override
  Map<String, dynamic> toMap() {
    var map = {
        'type': 'SheetTableCellBox',
        'id': id,
        'parentId': parentId,
        'indexPath': indexPath.toJson(),
        'data': data,
        'sheetItem': sheetItem.toMap(),
        'isVisible': isVisible,
        'hasError': hasError,
        'rowSpan': rowSpan,
        'colSpan': colSpan,
      };
      print(map);
    return map;
    } 

  factory SheetTableCellBox.fromMap(Map<String, dynamic> map) => 
  SheetTableCellBox(
        id: map['id'],
        parentId: map['parentId'],
        indexPath: IndexPath.fromJson(map['indexPath']),
        data: map['data'],
        sheetItem: SheetItem.fromMap(map['sheetItem']),
        isVisible: map['isVisible'],
        hasError: map['hasError'],
        rowSpan: map['rowSpan'],
        colSpan: map['colSpan'],
      );
  
  @override
  String toJson() => jsonEncode(toMap());

  factory SheetTableCellBox.fromJson(String json) =>
      SheetTableCellBox.fromMap(jsonDecode(json));

  
  }

  SheetText addTextField({
    required String id ,
    required String parentId,
    required Function findItem,
    required Function textFieldTapDown,
    required bool Function(int index, int length, Object? data) getReplaceTextFunctionForType(int i, QuillController q),
    required String name,
    required bool hide,
    required List<Map<String, dynamic>>
        docString, // Use List<Map<String, dynamic>> directly
    required SuperDecoration textDecoration,
    required IndexPath indexPath,
    required List<InputBlock> inputBlocks,
    SheetTextType type = SheetTextType.string,
    required bool locked,
  }) {
    Delta delta;
    // print('name: $name, and locked: $locked');
    // print('DocString: $docString');
    if (inputBlocks[0].indexPath.index ==-69) {
      inputBlocks=[InputBlock(indexPath: indexPath, blockIndex: [-2], id: id)];
    }
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
      // print('Decoded Delta: $delta');
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
    textController.onReplaceText = getReplaceTextFunctionForType(type.index ,textController);
    if (locked) {
      textController.onReplaceText =(int _, int _y, Object? _x)=>false;
    }
    String newId = id.isEmpty ? 'TX-${ const Uuid() .v4()}': id;
    var textEditorConfigurations = QuillEditorConfigurations(
      enableScribble: true,
      enableSelectionToolbar: true,
      autoFocus: true,
      onTapOutside: (event, focusNode) {
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
            fontSize:12,
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
        return textFieldTapDown(details, newId, indexPath);
      },
    );

    
    return SheetText(
      name:name,
      hide:hide,
      textEditorController: textController,
      textEditorConfigurations: textEditorConfigurations,
      id: newId,
      parentId:
          parentId,
      textDecoration: textDecoration, 
      indexPath: indexPath,
      inputBlocks: inputBlocks,
      type: type,
      locked: locked,
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
  