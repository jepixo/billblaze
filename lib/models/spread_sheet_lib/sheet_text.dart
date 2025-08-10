// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:fleather/fleather.dart';
// import 'dart:math';
import 'dart:convert';

import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_decoration.dart';
import 'package:billblaze/screens/layout_designer.dart'as ly; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<InputBlock> inputBlocks;
  @HiveField(8)
  int type;
  @HiveField(9)
  bool locked;

  SheetTextBox({
    required this.textDecoration,
    required this.textEditorController,
    required super.id,
    required super.parentId,
    required this.hide,
    required this.name,
    required super.indexPath,
    List<InputBlock>? inputBlocks,
    this.type = 0,
    required this.locked,
  }): inputBlocks = inputBlocks ?? [InputBlock(indexPath:indexPath, blockIndex: [-2],id: id)];

  @override
  Map<String, dynamic> toMap() {
    var map = {
        'type': 'SheetTextBox',
        'id': id,
        'parentId': parentId,
        'indexPath': indexPath.toJson(),
        'textEditorController': textEditorController,
        'textDecoration': textDecoration.toMap(),
        'name': name,
        'hide': hide,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'typeIndex': type,
        'locked': locked,
      };

      print('SheetTextBox: '+map.toString());
    return map;
    } 
  String toJson() => jsonEncode(toMap());

  factory SheetTextBox.fromMap(Map<String, dynamic> map) {
    print('in SheetTextBoxFromMap: '+map['id'].toString());
    print('in SheetTextBoxFromMap: '+map['textEditorController'].toString());
    return SheetTextBox(
      id: map['id'],
      parentId: map['parentId'],
      indexPath: IndexPath.fromJson(map['indexPath']),
      textEditorController: List<Map<String, dynamic>>.from(
          map['textEditorController'] as List),
      textDecoration: SuperDecorationBox.fromMap(map['textDecoration']),
      name: map['name'],
      hide: map['hide'],
      inputBlocks: (map['inputBlocks'] as List)
          .map((e) => InputBlock.fromMap(e))
          .toList(),
      type: map['typeIndex'], // renamed to avoid conflict with class name
      locked: map['locked'],
    );
  }

  factory SheetTextBox.fromJson(String json) =>
      SheetTextBox.fromMap(jsonDecode(json));
}

class SheetText extends SheetItem {
  final QuillController textEditorController;
  QuillEditorConfigurations textEditorConfigurations;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final QuillSimpleToolbarConfigurations toolBarConfigurations;
  String name;
  bool hide;
  SuperDecoration textDecoration;
  List<InputBlock> inputBlocks;
  SheetTextType type;
  bool locked;

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
    required this.type,
    required this.locked,
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
    List<InputBlock>? inputBlocks,
    SheetTextType type = SheetTextType.string,
    bool locked = false,
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
        inputBlocks: inputBlocks ?? [InputBlock(indexPath:indexPath, blockIndex: [-2], id: id)],
        type: type,
        locked: locked,
        );
  }

  Delta getTextEditorDocumentAsDelta() {
    return textEditorController.document.toDelta();
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
    List<InputBlock>? inputBlocks,
    SheetTextType? type, 
    bool? locked,
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
      type: type ?? this.type,
      locked: locked ?? this.locked,
    );
  }

  SheetTextBox toTEItemBox(SheetText item) {
    // print(
    //     'conversion text: ${item.textEditorController.document.toDelta().toJson()}');
    // print(
    //     'inputBlocks text: ${item.inputBlocks}');   
    // print('ToBOX name: ${item.name}, and locked: ${item.locked}');
    return SheetTextBox(
        textEditorController:
            textEditorController.document.toDelta().toJson(),
        id: item.id,
        parentId: item.parentId,
        hide: item.hide,
        name: item.name,
        indexPath: indexPath,
        textDecoration: item.textDecoration.toSuperDecorationBox(),
        inputBlocks: item.inputBlocks,
        type: item.type.index,
        locked: item.locked,
        );
  }

  void toggleVisibility(){
    hide = !hide;
  }

  void toggleLock(){
    locked = !locked;
  }

  void _toggleAttribute(Attribute attr) {
    final controller = textEditorController;
    final selection = controller.selection;
    final attrs = controller.getSelectionStyle().attributes;
    final isActive = attrs.containsKey(attr.key);

    if (selection.isCollapsed) {
      // Apply/remove to the whole document
      final docLength = controller.document.length - 1;
      controller.formatText(0, docLength, isActive ? Attribute.clone(attr, null) : attr);
    } else {
      controller.formatSelection(isActive ? Attribute.clone(attr, null) : attr);
    }
  }


  /// Toggle a block‐level alignment attribute.  
  /// - If there’s a non-collapsed selection, it applies to every block spanned.  
  /// - If the cursor is collapsed, it applies only to the single block (line) containing the cursor.
  void _setAlignment( Attribute alignment) {
    final controller = textEditorController;
    final sel = controller.selection;
    final attrs = controller.getSelectionStyle().attributes;
    final current = attrs[Attribute.align.key];

    // Decide whether we’re turning this alignment on or off:
    final apply = (current == alignment)
        ? Attribute.clone(alignment, null) // turn it off
        : alignment;                       // turn it on

    if (!sel.isCollapsed) {
      // Just format the whole selection span:
      controller.formatSelection(apply);
      return;
    }

    // Collapsed cursor → we only want the one block/line containing the cursor.
    // FlutterQuill lays out the document as a sequence of block‐nodes (Lines).
    // We can scan through top‐level children until we find which one contains our offset.

    if (controller.editorFocusNode?.hasFocus??true) {
      final doc = controller.document;
      int runningOffset = 0;

      for (final node in doc.root.children) {
        final blockLength = node.length; // includes the trailing '\n'
        if (sel.baseOffset >= runningOffset && sel.baseOffset < runningOffset + blockLength) {
          // Found the block that contains our cursor:
          controller.formatText(runningOffset, blockLength, apply);
          return;
        }
        runningOffset += blockLength;
      }
    }
    // Fallback: if something weird happened, just apply to entire document:
    controller.formatText(0, controller.document.length - 1, apply);
  }



  // Text style toggles
  void toggleBold() => _toggleAttribute(Attribute.bold);
  void toggleItalic() => _toggleAttribute(Attribute.italic);
  void toggleUnderline() => _toggleAttribute(Attribute.underline);
  void toggleStrikeThrough() => _toggleAttribute(Attribute.strikeThrough);

  // Alignment toggles (clears others if same)
  void alignLeft() => _setAlignment(Attribute.leftAlignment);
  void alignCenter() => _setAlignment(Attribute.centerAlignment);
  void alignRight() => _setAlignment(Attribute.rightAlignment);
  void alignJustify() => _setAlignment(Attribute.justifyAlignment);

  // Block style toggles
  void toggleBlockQuote() => _toggleAttribute(Attribute.blockQuote);
  void toggleCodeBlock() => _toggleAttribute(Attribute.codeBlock);
  void toggleOrderedList() => _toggleAttribute(Attribute.ol);
  void toggleUnorderedList() => _toggleAttribute(Attribute.ul);

  // Baseline styles
  /// Toggle subscript—but first clear superscript if it’s active.
void toggleSubscript() => _toggleScript(
      onAttr: Attribute.subscript,
      offAttr: Attribute.superscript,
    );

/// Toggle superscript—but first clear subscript if it’s active.
void toggleSuperscript() => _toggleScript(
      onAttr: Attribute.superscript,
      offAttr: Attribute.subscript,
    );

/// Toggles [onAttr] and ensures [offAttr] is cleared first, all in one call.
void _toggleScript({
  required Attribute onAttr,
  required Attribute offAttr,
}) {
  final c = textEditorController;
  final sel = c.selection;
  final attrs = c.getSelectionStyle().attributes;

  final hasOn  = attrs.containsKey(onAttr.key);
  final hasOff = attrs.containsKey(offAttr.key);

  void apply(Attribute a) {
    if (sel.isCollapsed) {
      final len = c.document.length - 1;
      c.formatText(0, len, a);
    } else {
      c.formatSelection(a);
    }
  }

  if (hasOn) {
    // Currently on → clear it
    apply(Attribute.clone(onAttr, null));
  } else {
    // Off → clear the other if needed, then set this one
    if (hasOff) apply(Attribute.clone(offAttr, null));
    apply(onAttr);
  }
}
/// Change the font size (e.g. 14, 18, 22).
void updateFontSize( double newSize) {
  final controller = textEditorController;
  final attr = Attribute.size; // built‑in size attribute
  final value = newSize.toString();
  _applyOrFormat((String v) => Attribute.clone(Attribute.size, v), value);
}

/// Change the letter spacing (CSS “letter-spacing”) in px units.
void updateLetterSpacing( double spacing) {
  final controller = textEditorController;
  final attr = ly.LetterSpacingAttribute; // custom from flutter_quill
  final value = spacing.toString();
  _applyOrFormat((String v) => ly.LetterSpacingAttribute(v), value);
}

/// Change the word spacing (CSS “word-spacing”) in px units.
void updateWordSpacing( double spacing) {
  final controller = textEditorController;
  final attr = ly.WordSpacingAttribute;
  final value = spacing.toString();
  _applyOrFormat((String v) => ly.WordSpacingAttribute(v), value);
}

/// Change the line height (CSS “line-height”), e.g. 1.2, 1.5, 2.0.
void updateLineHeight( double height) {
  final controller = textEditorController;
  final attr = ly.LineHeightAttribute;
  final value = height.toString();
  _applyOrFormat((String v) => ly.LineHeightAttribute(v), value);
}

/// otherwise we format the entire document.
void _applyOrFormat(
  
  Attribute Function(String) attributeBuilder,
  String value,
) {
  final controller = textEditorController;
  final formattedAttr = attributeBuilder(value);
  final sel = controller.selection;

  if (sel.isCollapsed) {
    // apply to whole document
    final docLen = controller.document.length - 1;
    controller.formatText(0, docLen, formattedAttr);
  } else {
    // apply only to selection
    controller.formatSelection(formattedAttr);
  }
}

  void updateColor(Color color) {
    final controller = textEditorController;
    final selection = controller.selection;
    final attr = ColorAttribute('#${colorToHex(color)}');

    if (selection.isCollapsed) {
      final length = controller.document.length - 1;
      controller.formatText(0, length, attr);
    } else {
      controller.formatSelection(attr);
    }

    // Optionally update hex text field
    final newColorAttr = controller.getSelectionStyle().attributes['color'];
  }
  
  void updateFontFamily(String fontName) {
    final controller = textEditorController;

    final fontValue = GoogleFonts.getFont(fontName).fontFamily;
    final attr = Attribute.fromKeyValue(
      Attribute.font.key,
      fontName == 'Clear' ? null : GoogleFonts.getFont(fontName).fontFamily,
    );

    final selection = controller.selection;
    if (selection.isCollapsed) {
      final docLength = controller.document.length - 1;
      controller.formatText(0, docLength, attr);
    } else {
      controller.formatSelection(attr);
    }
  }


}


enum SheetTextType {
  string,
  number,
  integer,
  bool,
  date,
  time,
  email,
  url,
  phone,
  choice,
  currency,

}