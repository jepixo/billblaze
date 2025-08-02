// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:billblaze/home.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/screens/layout_designer.dart' as ly;
part 'sheet_functions.g.dart';

@HiveType(typeId:16)
class SheetFunction {
  @HiveField(0)
  final int returnType;
  @HiveField(1)
  final String name;
  
  

  SheetFunction(this.returnType, this.name);

  dynamic result(Function getItemAtPath,
   Function buildCombinedQuillConfiguration,
  {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    throw UnimplementedError('Subclasses must override result()');
  }
  Map<String, dynamic> toMap() {
    throw UnimplementedError('Subclasses must override toMap()');
  }

  static SheetFunction fromMap(Map<String, dynamic> map) {
    print('SheetFunction type: '+map['type']);
    switch (map['type']) {
      case 'sum':
        return SumFunction.fromMap(map);
      case 'column':
        return ColumnFunction.fromMap(map);
      case 'count':
        return CountFunction.fromMap(map);
      case 'inputBlock':
        return InputBlockFunction.fromMap(map);

      // Add more subclasses here if needed
      default:
        throw Exception('Unknown SheetFunction type: ${map['type']}');
    }
  }

  String toJson() => jsonEncode(toMap());
  static SheetFunction fromJson(String json) => fromMap(jsonDecode(json));

}

@HiveType(typeId:17)
class SumFunction extends SheetFunction {
  @HiveField(2)
  List<InputBlock> inputBlocks;
  @HiveField(3)
  List<Map<String, dynamic>> resultJson =[];

  SumFunction( this.inputBlocks,[this.resultJson = const []]) : super(1, 'sum');

  @override
  dynamic result(
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration, {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    double sum = 0;
    visited ??= {};

    // recursion guard
    visited[inputBlocks] = (visited[inputBlocks] ?? 0) + 1;
    if (visited[inputBlocks]! > 50) {
      return 'recursion detected';
    }

    for (final block in inputBlocks) {
      dynamic raw;

      // 1) nested formula
      if (block.function != null && !block.useConst) {
        if (block.function is InputBlockFunction) {
          raw = (block.function as InputBlockFunction).getConfigurations(
            buildCombinedQuillConfiguration,
            spreadSheet: spreadSheet,
            visited: visited,
            ).controller.document;
        } else{
          raw = block.function!.result(
            getItemAtPath,
            buildCombinedQuillConfiguration,
            spreadSheet: spreadSheet,
            visited: Map.from(visited),
          );
        }
      }
      else {
        // 2) live editor text
        final item = spreadSheet == null
          ? getItemAtPath(block.indexPath)
          : getItemAtPath(block.indexPath, spreadSheet);

        if (item is SheetText) {
          raw = item.textEditorConfigurations.controller
            .document
            .toPlainText()
            .trim();
        } else if (item is SheetTextBox) {
          raw = Document.fromDelta(
            Delta.fromJson(item.textEditorController as List)
          ).toPlainText().trim();
        }
      }

      // now normalize whatever raw is
      if (raw is num) {
        sum += raw.toDouble();
      } else if (raw is String) {
        sum += double.tryParse(raw) ?? 0.0;
      } else if (raw is Document) {
        sum += double.tryParse(raw.toPlainText().trim()) ?? 0.0;
      }
    }

    // ─── preserve styling in resultJson ─────────────────────────────────
    final oldDelta = Delta.fromJson(resultJson);
    // grab the first op’s attrs if any
    final firstAttrs = oldDelta.isNotEmpty ? oldDelta.toList().first.attributes : null;

    // build new one-op delta
    final newDelta = Delta()..insert(
      '${sum}\n',
      firstAttrs,
    );

    final newJson = newDelta.toJson();
    if (newJson != resultJson) {
      resultJson = newJson;
    }

    // return the same type you were using (e.g. String or Document)
    // if external code expects String, return resultJson; otherwise:
    return Document.fromDelta(newDelta);
  }

  QuillEditorConfigurations getConfigurations (
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration,
    Function setState,
    Function customStyleBuilder,
    {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    return QuillEditorConfigurations(
      controller: QuillController(
        document: result(getItemAtPath, buildCombinedQuillConfiguration), 
        selection: TextSelection.collapsed(offset: 0),
        onReplaceText: (_, __, ___) {
          // setState(() {});
          return true;
        },
        ),
        enableScribble: true,
        enableSelectionToolbar: true,
        autoFocus: true,
        contextMenuBuilder: (context, rawEditorState) {
          return Container();
        },
        customStyleBuilder: (attribute) {
          return customStyleBuilder(attribute); // Default style
        },
      );
  }
  
  
  @override
  Map<String, dynamic> toMap() => {
        'type': 'sum',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'resultJson': resultJson,
      };

  factory SumFunction.fromMap(Map<String, dynamic> map) => SumFunction(
        (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        map['resultJson']
      );
  
  void _toggleAttribute(Attribute attr, QuillController controller) {
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
  void _setAlignment( Attribute alignment, QuillController controller) {
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
  void toggleBold(QuillController controller) => _toggleAttribute(Attribute.bold, controller);
  void toggleItalic(QuillController controller) => _toggleAttribute(Attribute.italic, controller);
  void toggleUnderline(QuillController controller) => _toggleAttribute(Attribute.underline, controller);
  void toggleStrikeThrough(QuillController controller) => _toggleAttribute(Attribute.strikeThrough, controller);

  // Alignment toggles (clears others if same)
  void alignLeft(QuillController controller) => _setAlignment(Attribute.leftAlignment, controller);
  void alignCenter(QuillController controller) => _setAlignment(Attribute.centerAlignment, controller);
  void alignRight(QuillController controller) => _setAlignment(Attribute.rightAlignment, controller);
  void alignJustify(QuillController controller) => _setAlignment(Attribute.justifyAlignment, controller);

  // Block style toggles
  void toggleBlockQuote(QuillController controller) => _toggleAttribute(Attribute.blockQuote, controller );
  void toggleCodeBlock(QuillController controller) => _toggleAttribute(Attribute.codeBlock, controller);
  void toggleOrderedList(QuillController controller) => _toggleAttribute(Attribute.ol, controller);
  void toggleUnorderedList(QuillController controller) => _toggleAttribute(Attribute.ul, controller);

  // Baseline styles
  /// Toggle subscript—but first clear superscript if it’s active.
void toggleSubscript(QuillController controller) => _toggleScript(
      onAttr: Attribute.subscript,
      offAttr: Attribute.superscript,
      c: controller
    );

/// Toggle superscript—but first clear subscript if it’s active.
void toggleSuperscript(QuillController controller) => _toggleScript(
      onAttr: Attribute.superscript,
      offAttr: Attribute.subscript,
      c: controller
    );

/// Toggles [onAttr] and ensures [offAttr] is cleared first, all in one call.
void _toggleScript({
  required Attribute onAttr,
  required Attribute offAttr,
  required QuillController c
}) {
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
void updateFontSize( double newSize, QuillController controller) {
  final attr = Attribute.size; // built‑in size attribute
  final value = newSize.toString();
  _applyOrFormat((String v) => Attribute.clone(Attribute.size, v), value, controller);
}

/// Change the letter spacing (CSS “letter-spacing”) in px units.
void updateLetterSpacing( double spacing, QuillController controller) {
  final value = spacing.toString();
  _applyOrFormat((String v) => ly.LetterSpacingAttribute(v), value, controller);
}

/// Change the word spacing (CSS “word-spacing”) in px units.
void updateWordSpacing( double spacing, QuillController controller) {
  final value = spacing.toString();
  _applyOrFormat((String v) => ly.WordSpacingAttribute(v), value, controller);
}

/// Change the line height (CSS “line-height”), e.g. 1.2, 1.5, 2.0.
void updateLineHeight( double height, QuillController controller) {
  final value = height.toString();
  _applyOrFormat((String v) => ly.LineHeightAttribute(v), value, controller);
}

/// otherwise we format the entire document.
void _applyOrFormat(
  
  Attribute Function(String) attributeBuilder,
  String value,
  QuillController controller
) {
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

  void updateColor(Color color, QuillController controller) {
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
  
  void updateFontFamily(String fontName, QuillController controller) {

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

@HiveType(typeId:19)
class ColumnFunction extends SheetFunction {
  @HiveField(2)
  List<InputBlock> inputBlocks;

  @HiveField(3)
  String func;

  @HiveField(4)
  String axisLabel;

  @HiveField(5)
  List<Map<String, dynamic>> resultJson =[];

  ColumnFunction({required this.inputBlocks, required this.func, required this.axisLabel,this.resultJson = const []}) : super(0, 'column');

  @override
  dynamic result(Function getItemAtPath,
   Function buildCombinedQuillConfiguration,
   {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    switch (func) {
      case 'sum':
      // print(inputBlocks);
      var sumfunc = SumFunction(inputBlocks);
        // print(sumfunc.result(getItemAtPath, spreadSheet: spreadSheet).toString());
        return SumFunction(inputBlocks).result(getItemAtPath, buildCombinedQuillConfiguration, spreadSheet: spreadSheet, visited: visited);
      
      case 'count':
        return CountFunction(inputBlocks: inputBlocks).result(getItemAtPath,buildCombinedQuillConfiguration, spreadSheet: spreadSheet,visited: visited);
      default:
      return 0;
    }
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 'column',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'func': func,
        'axisLabel': axisLabel,
        'resultJson': resultJson,
      };

  factory ColumnFunction.fromMap(Map<String, dynamic> map) => ColumnFunction(
      inputBlocks: 
        (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        func:
            map['func'],
        axisLabel: map['axisLabel'],
        resultJson: map['resultJson'],

      );

}

@HiveType(typeId:20)
class CountFunction extends SheetFunction {
  @HiveField(2)
  List<InputBlock> inputBlocks;
  @HiveField(3)
  List<Map<String, dynamic>> resultJson =[];

  @override
  dynamic result(
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration, {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    int count = 0;

    for (final block in inputBlocks) {
      // Case A: nested ColumnFunction(…, func: 'count')
      if (block.function is ColumnFunction &&
          (block.function as ColumnFunction).func == 'count' &&
          !block.useConst) {
        final nested = (block.function as ColumnFunction).result(
          getItemAtPath,
          buildCombinedQuillConfiguration,
          spreadSheet: spreadSheet,
          visited: visited == null ? null : Map.from(visited),
        );
        if (double.tryParse(nested.toPlainText()) != null) {
          count += double.tryParse(nested.toPlainText())!.toInt();
          continue;
        }
      }

      // Otherwise each block counts as 1
      count += 1;
    }

    // ─── preserve styling in resultJson ─────────────────────────────────
    // Build a one-op delta with the old attributes
    final oldDelta = Delta.fromJson(resultJson);
    final firstAttrs =
        oldDelta.isNotEmpty ? oldDelta.toList().first.attributes : null;

    final newDelta = Delta()..insert('$count\n', firstAttrs);
    final newJson = newDelta.toJson();

    if (newJson != resultJson) {
      resultJson = newJson;
    }

    // Return the same type as your sum: a Quill Document
    return Document.fromDelta(newDelta);
  }


  CountFunction(
    {required this.inputBlocks,this.resultJson = const []}
  ):super(1,'count');

   @override
  Map<String, dynamic> toMap() => {
        'type': 'count',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'resultJson': resultJson,
      };

  factory CountFunction.fromMap(Map<String, dynamic> map) => CountFunction(
        inputBlocks: (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        resultJson: map['resultJson'],
      );

}

@HiveType(typeId: 21)
class InputBlockFunction extends SheetFunction {
  @HiveField(2)
  List<InputBlock> inputBlocks;
  @HiveField(3)
  String label;

  InputBlockFunction(
    {
      required this.inputBlocks,
      required this.label,
    }
  ):super(0,'inputBlock');

  @override
  result(Function getItemAtPath, Function buildCombinedQuillConfiguration, {List<SheetListBox>? spreadSheet,Map<List<InputBlock>, int>? visited,}) {
    if (spreadSheet!=null) {
      return buildCombinedTextFromBlocks(inputBlocks, spreadSheet);
    }
  }

  QuillEditorConfigurations getConfigurations(buildCombinedQuillConfiguration, {List<SheetListBox>? spreadSheet,Map<List<InputBlock>, int>? visited,}) {
    if (spreadSheet !=null) {
      var rawText = buildCombinedQuillConfiguration(inputBlocks, spreadSheet, visited:visited==null?null: Map<List<InputBlock>, int>.from(visited));
      return QuillEditorConfigurations(controller: QuillController(document: Document()..insert(0, rawText), selection: TextSelection.collapsed(offset: 0)));
    }
    return buildCombinedQuillConfiguration(inputBlocks, visited: visited==null?null: Map<List<InputBlock>, int>.from(visited) );
  }
  
  @override
  Map<String, dynamic> toMap() => {
        'type': 'inputBlock',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'label': label

      };

  factory InputBlockFunction.fromMap(Map<String, dynamic> map) => InputBlockFunction(
        inputBlocks: (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        label: map['label'],
        
      );

}
///
///
///
///
class IfFunction extends SheetFunction {
  IfFunction():super(1,'if');
}

class UniqueFunction extends SheetFunction {
  UniqueFunction():super(1,'unique');
}

class TextBeforeFunction extends SheetFunction {
  TextBeforeFunction():super(0,'textBefore');
}

class TextAfterFunction extends SheetFunction {
  TextAfterFunction():super(0, 'textAfter');

}

class AndFunction extends SheetFunction {
  AndFunction():super(2, 'and');
}

class OrFunction extends SheetFunction {
  OrFunction():super(2, 'or');
}

class NotFunction extends SheetFunction {
  NotFunction():super(2,'not');
}

class MapFunction extends SheetFunction {
  MapFunction(super.returnType,super.name);
  
}

class SwitchFunction extends SheetFunction {
  SwitchFunction(super.returnType,super.name);

}

class XORFunction extends SheetFunction {
  XORFunction():super(2, 'xor');
}

// true false null and empty
// lambda functions
