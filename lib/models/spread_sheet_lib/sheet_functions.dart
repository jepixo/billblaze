// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'package:billblaze/home.dart';
import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
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
      case 'average':
        return AverageFunction.fromMap(map);

      // Add more subclasses here if needed
      default:
        throw Exception('Unknown SheetFunction type: ${map['type']}');
    }
  }

  String toJson() => jsonEncode(toMap());
  static SheetFunction fromJson(String json) => fromMap(jsonDecode(json));

}

@HiveType(typeId:17)
class SumFunction extends SheetFunction with QuillFormattingMixin{
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
    // final oldDelta = Delta.fromJson(resultJson);
    // // grab the first op’s attrs if any
    // final firstAttrs = oldDelta.isNotEmpty ? oldDelta.toList().first.attributes : null;

    // // build new one-op delta
    // final newDelta = Delta()..insert(
    //   '${sum}\n',
    //   firstAttrs,
    // );
    final oldDelta = Delta.fromJson(resultJson);
    final oldOps = oldDelta.toList();
    var newText = sum.toString();
    // 2) We’ll build a brand‐new Delta:
    final newDelta = Delta();
    int written = 0; // how many chars of newText we've consumed

    // 3) Replay old attribute spans:
    for (final op in oldOps) {
      if (written >= newText.length) break; // no more new text to style

      final data = op.data;
      final attrs = op.attributes;
      if (data is String && data.isNotEmpty) {
        // how many chars this old-op covered:
        final span = data.length;
        // how many chars we can take from newText under this span:
        final take = (newText.length - written).clamp(0, span);
        // grab that substring:
        final slice = newText.substring(written, written + take);
        if (slice.isNotEmpty) {
          newDelta.insert(slice, attrs);
          written += take;
        }
      }
      // if op was an embed or something else, you can handle here…
    }

    // 4) If there’s any leftover newText (should be rare), just insert unstyled:
    if (written < newText.length) {
      newDelta.insert(newText.substring(written));
    }

    // 5) Finally, append the newline “\n”:
    //    We want to preserve whatever styling the old trailing newline had:
    //    search the oldOps *in reverse* for the first op whose data ends in '\n'
    Map<String,dynamic>? newlineAttrs;
    for (final op in oldOps.reversed) {
      if (op.data is String && (op.data as String).endsWith('\n')) {
        newlineAttrs = op.attributes;
        break;
      }
    }
    // default to no attributes if none found:
    newDelta.insert('\n', newlineAttrs);

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
class CountFunction extends SheetFunction with QuillFormattingMixin{
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
    final oldDelta = Delta.fromJson(resultJson);
    final oldOps = oldDelta.toList();
    var newText = count.toString();
    // 2) We’ll build a brand‐new Delta:
    final newDelta = Delta();
    int written = 0; // how many chars of newText we've consumed

    // 3) Replay old attribute spans:
    for (final op in oldOps) {
      if (written >= newText.length) break; // no more new text to style

      final data = op.data;
      final attrs = op.attributes;
      if (data is String && data.isNotEmpty) {
        // how many chars this old-op covered:
        final span = data.length;
        // how many chars we can take from newText under this span:
        final take = (newText.length - written).clamp(0, span);
        // grab that substring:
        final slice = newText.substring(written, written + take);
        if (slice.isNotEmpty) {
          newDelta.insert(slice, attrs);
          written += take;
        }
      }
      // if op was an embed or something else, you can handle here…
    }

    // 4) If there’s any leftover newText (should be rare), just insert unstyled:
    if (written < newText.length) {
      newDelta.insert(newText.substring(written));
    }

    // 5) Finally, append the newline “\n”:
    //    We want to preserve whatever styling the old trailing newline had:
    //    search the oldOps *in reverse* for the first op whose data ends in '\n'
    Map<String,dynamic>? newlineAttrs;
    for (final op in oldOps.reversed) {
      if (op.data is String && (op.data as String).endsWith('\n')) {
        newlineAttrs = op.attributes;
        break;
      }
    }
    // default to no attributes if none found:
    newDelta.insert('\n', newlineAttrs);

    final newJson = newDelta.toJson();
    if (newJson != resultJson) {
      resultJson = newJson;
    }

    // Return the same type as your sum: a Quill Document
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

@HiveType(typeId: 22)
class AverageFunction extends SheetFunction with QuillFormattingMixin {
  @HiveField(2)
  List<InputBlock> inputBlocks;
  @HiveField(3)
  List<Map<String, dynamic>> resultJson =[];

  AverageFunction(
    {required this.inputBlocks,this.resultJson = const []}
  ):super(1,'average');

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
    // final oldDelta = Delta.fromJson(resultJson);
    // // grab the first op’s attrs if any
    // final firstAttrs = oldDelta.isNotEmpty ? oldDelta.toList().first.attributes : null;

    // // build new one-op delta
    // final newDelta = Delta()..insert(
    //   '${sum}\n',
    //   firstAttrs,
    // );
    final avg = sum/inputBlocks.length;
    final oldDelta = Delta.fromJson(resultJson);
    final oldOps = oldDelta.toList();
    var newText = avg.toString();
    // 2) We’ll build a brand‐new Delta:
    final newDelta = Delta();
    int written = 0; // how many chars of newText we've consumed

    // 3) Replay old attribute spans:
    for (final op in oldOps) {
      if (written >= newText.length) break; // no more new text to style

      final data = op.data;
      final attrs = op.attributes;
      if (data is String && data.isNotEmpty) {
        // how many chars this old-op covered:
        final span = data.length;
        // how many chars we can take from newText under this span:
        final take = (newText.length - written).clamp(0, span);
        // grab that substring:
        final slice = newText.substring(written, written + take);
        if (slice.isNotEmpty) {
          newDelta.insert(slice, attrs);
          written += take;
        }
      }
      // if op was an embed or something else, you can handle here…
    }

    // 4) If there’s any leftover newText (should be rare), just insert unstyled:
    if (written < newText.length) {
      newDelta.insert(newText.substring(written));
    }

    // 5) Finally, append the newline “\n”:
    //    We want to preserve whatever styling the old trailing newline had:
    //    search the oldOps *in reverse* for the first op whose data ends in '\n'
    Map<String,dynamic>? newlineAttrs;
    for (final op in oldOps.reversed) {
      if (op.data is String && (op.data as String).endsWith('\n')) {
        newlineAttrs = op.attributes;
        break;
      }
    }
    // default to no attributes if none found:
    newDelta.insert('\n', newlineAttrs);

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
        'type':'average',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'resultJson': resultJson,
      };

  factory AverageFunction.fromMap(Map<String, dynamic> map) => AverageFunction(
        inputBlocks: (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        resultJson: map['resultJson']
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

mixin QuillFormattingMixin on SheetFunction {
  /// All implementing classes must have:
  /// `late List<Map<String, dynamic>> resultJson;`
  List<Map<String, dynamic>> get resultJson;
  set resultJson(List<Map<String, dynamic>> v);

  void _toggleAttribute(Attribute attr, QuillController controller) {
    final selection = controller.selection;
    final attrs = controller.getSelectionStyle().attributes;
    final isActive = attrs.containsKey(attr.key);

    if (selection.isCollapsed) {
      final docLength = controller.document.length - 1;
      controller.formatText(
        0,
        docLength,
        isActive ? Attribute.clone(attr, null) : attr,
      );
    } else {
      controller.formatSelection(
        isActive ? Attribute.clone(attr, null) : attr,
      );
    }

    resultJson = controller.document.toDelta().toJson();
  }

  void _setAlignment(Attribute alignment, QuillController controller) {
    final sel = controller.selection;
    final attrs = controller.getSelectionStyle().attributes;
    final current = attrs[Attribute.align.key];
    final apply = (current == alignment)
        ? Attribute.clone(alignment, null)
        : alignment;

    if (!sel.isCollapsed) {
      controller.formatSelection(apply);
      resultJson = controller.document.toDelta().toJson();
      return;
    }

    final doc = controller.document;
    int runningOffset = 0;

    for (final node in doc.root.children) {
      final blockLength = node.length;
      if (sel.baseOffset >= runningOffset &&
          sel.baseOffset < runningOffset + blockLength) {
        controller.formatText(runningOffset, blockLength, apply);
        resultJson = controller.document.toDelta().toJson();
        return;
      }
      runningOffset += blockLength;
    }

    // fallback → whole doc
    controller.formatText(0, controller.document.length - 1, apply);
    resultJson = controller.document.toDelta().toJson();
  }

  // ───── Text style toggles ─────
  void toggleBold(QuillController c) => _toggleAttribute(Attribute.bold, c);
  void toggleItalic(QuillController c) => _toggleAttribute(Attribute.italic, c);
  void toggleUnderline(QuillController c) => _toggleAttribute(Attribute.underline, c);
  void toggleStrikeThrough(QuillController c) =>
      _toggleAttribute(Attribute.strikeThrough, c);

  // ───── Alignment toggles ─────
  void alignLeft(QuillController c) => _setAlignment(Attribute.leftAlignment, c);
  void alignCenter(QuillController c) => _setAlignment(Attribute.centerAlignment, c);
  void alignRight(QuillController c) => _setAlignment(Attribute.rightAlignment, c);
  void alignJustify(QuillController c) => _setAlignment(Attribute.justifyAlignment, c);

  // ───── Block styles ─────
  void toggleBlockQuote(QuillController c) => _toggleAttribute(Attribute.blockQuote, c);
  void toggleCodeBlock(QuillController c) => _toggleAttribute(Attribute.codeBlock, c);
  void toggleOrderedList(QuillController c) => _toggleAttribute(Attribute.ol, c);
  void toggleUnorderedList(QuillController c) => _toggleAttribute(Attribute.ul, c);

  // ───── Script styles ─────
  void toggleSubscript(QuillController c) =>
      _toggleScript(onAttr: Attribute.subscript, offAttr: Attribute.superscript, c: c);

  void toggleSuperscript(QuillController c) =>
      _toggleScript(onAttr: Attribute.superscript, offAttr: Attribute.subscript, c: c);

  void _toggleScript({
    required Attribute onAttr,
    required Attribute offAttr,
    required QuillController c,
  }) {
    final sel = c.selection;
    final attrs = c.getSelectionStyle().attributes;
    final hasOn = attrs.containsKey(onAttr.key);
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
      apply(Attribute.clone(onAttr, null));
    } else {
      if (hasOff) apply(Attribute.clone(offAttr, null));
      apply(onAttr);
    }
    resultJson = c.document.toDelta().toJson();
  }

  // ───── Font & spacing updates ─────
  void updateFontSize(double newSize, QuillController c) {
    _applyOrFormat((v) => Attribute.clone(Attribute.size, v), newSize.toString(), c);
  }

  void updateLetterSpacing(double spacing, QuillController c) {
    _applyOrFormat((v) => ly.LetterSpacingAttribute(v), spacing.toString(), c);
  }

  void updateWordSpacing(double spacing, QuillController c) {
    _applyOrFormat((v) => ly.WordSpacingAttribute(v), spacing.toString(), c);
  }

  void updateLineHeight(double height, QuillController c) {
    _applyOrFormat((v) => ly.LineHeightAttribute(v), height.toString(), c);
  }

  void updateColor(Color color, QuillController c) {
    final attr = ColorAttribute('#${colorToHex(color)}');
    if (c.selection.isCollapsed) {
      final len = c.document.length - 1;
      c.formatText(0, len, attr);
    } else {
      c.formatSelection(attr);
    }
    resultJson = c.document.toDelta().toJson();
  }

  void updateFontFamily(String fontName, QuillController c) {
    final attr = Attribute.fromKeyValue(
      Attribute.font.key,
      fontName == 'Clear' ? null : GoogleFonts.getFont(fontName).fontFamily,
    );

    if (c.selection.isCollapsed) {
      final len = c.document.length - 1;
      c.formatText(0, len, attr);
    } else {
      c.formatSelection(attr);
    }
    resultJson = c.document.toDelta().toJson();
  }

  // Shared helper
  void _applyOrFormat(
    Attribute Function(String) attrBuilder,
    String value,
    QuillController c,
  ) {
    final attr = attrBuilder(value);
    if (c.selection.isCollapsed) {
      final len = c.document.length - 1;
      c.formatText(0, len, attr);
    } else {
      c.formatSelection(attr);
    }
    resultJson = c.document.toDelta().toJson();
  }
}
