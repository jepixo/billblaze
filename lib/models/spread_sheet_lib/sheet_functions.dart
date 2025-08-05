// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:math';

import 'package:billblaze/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
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
      case 'column':
        return ColumnFunction.fromMap(map);
      case 'inputBlock':
        return InputBlockFunction.fromMap(map);
      case 'unistat':
        return UniStatFunction.fromMap(map);

      // Add more subclasses here if needed
      default:
        throw Exception('Unknown SheetFunction type: ${map['type']}');
    }
  }

  String toJson() => jsonEncode(toMap());
  static SheetFunction fromJson(String json) => fromMap(jsonDecode(json));

}

@HiveType(typeId: 17)
class UniStatFunction extends SheetFunction with QuillFormattingMixin {
  @HiveField(2)
  List<InputBlock> inputBlocks;

  @HiveField(3)
  List<Map<String, dynamic>> resultJson = [];

  @HiveField(4)
  String func;

  UniStatFunction({
    required this.inputBlocks,
    this.resultJson = const [],
    required this.func,
  }) : super(1, 'unistat');

  // ──────────────────────────────
  // MAIN RESULT ENTRYPOINT
  // ──────────────────────────────
  @override
  dynamic result(
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration, {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    visited ??= {};
    visited[inputBlocks] = (visited[inputBlocks] ?? 0) + 1;

    if (visited[inputBlocks]! > 50) {
      return 'recursion detected';
    }

    // Extract all numeric values first
    final (values,count) = _collectValues(getItemAtPath, buildCombinedQuillConfiguration,
        spreadSheet: spreadSheet, visited: visited);
    // print(count);
    // Compute based on `func`
    String newText;
    switch (func.toLowerCase()) {
      case 'sum':
        newText = _sum(values).toString();
        break;
      case 'product':
        newText = _product(values).toString();
        break;
      case 'count':
        newText = count.toString();
        break;
      case 'min':
        newText = values.reduce(min).toString();
      case 'max':
        newText = values.reduce(max).toString();
      case 'average':
      case 'mean':
        newText = _average(values).toString();
        break;
      case 'median':
        newText = _median(values).toString();
        break;
      case 'mode':
        newText = _mode(values).toString();
        break;
      case 'range':
        newText = _range(values).toString();
        break;
      case 'range ratio':
        newText = values.isEmpty || values.reduce(min) == 0
            ? 'NaN'
            : (values.reduce(max) / values.reduce(min)).toString();
        break;
      case 'variance':
        newText = _variance(values).toString();
        break;
      case 'stddev':
      case 'standard deviation':
        newText = _stdDev(values).toString();
        break;
      case 'mad':
      case 'mean absolute deviation':
        newText = _mad(values).toString();
        break;
      case 'skewness':
        print('skew: '+_skewness(values).toString());
        newText = _skewness(values).toString();
        break;
      case 'kurtosis':
        newText = _kurtosis(values).toString();
        break;
      case 'geomean':
      case 'geometric mean':
        newText =  pow(values.fold(1.0, (a, b) => a * b), 1 / values.length).toString();
      case 'harmean':
      case 'harmonic mean':
        newText =  (values.length / values.map((x) => 1 / x).reduce((a, b) => a + b)).toString();
      case 'quadratic mean (rms)':
        newText = values.isEmpty
            ? '0'
            : sqrt(values.map((x) => x * x).reduce((a, b) => a + b) / values.length).toString();
        break;
      case 'sum of cubes':
        newText = values.map((x) => x * x * x).reduce((a, b) => a + b).toString();
        break;
      case 'root mean cube':
        newText = values.isEmpty
            ? '0'
            : pow(values.map((x) => x * x * x).reduce((a, b) => a + b) / values.length, 1 / 3)
                .toString();
        break;
      case 'energy (sum of squares)':
        newText = values.map((x) => x * x).reduce((a, b) => a + b).toString();
        break;
      case 'percentile (p)':
        newText = _percentile(values, 50).toString(); // default to median if p not set
        break;
      case 'quartiles (q1,q3)':
        final q1 = _percentile(values, 25);
        final q3 = _percentile(values, 75);
        newText = '$q1, $q3';
        break;
      default:
        newText = 'NaN';
        break;

    }

    // Preserve styling in resultJson
    final oldDelta = Delta.fromJson(resultJson);
    final oldOps = oldDelta.toList();
    final newDelta = _applyStylingFromOldOps(oldOps, newText);

    // Update resultJson if changed
    final newJson = newDelta.toJson();
    if (newJson != resultJson) {
      resultJson = newJson;
    }

    return Document.fromDelta(newDelta);
  }

  // ──────────────────────────────
  // VALUE COLLECTION
  // ──────────────────────────────
  (List<double>, int) _collectValues(
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration, {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    final values = <double>[];
    int baseCount =0;
    for (final block in inputBlocks) {
      dynamic raw;

      // Nested function handling
      if (block.function != null && !block.useConst) {
        if (block.function is InputBlockFunction) {
          raw = (block.function as InputBlockFunction)
              .getConfigurations(buildCombinedQuillConfiguration,
                  spreadSheet: spreadSheet, visited: visited)
              .controller
              .document;
        } else {
          raw = block.function!.result(
            getItemAtPath,
            buildCombinedQuillConfiguration,
            spreadSheet: spreadSheet,
            visited: Map.from(visited!),
          );
        }
        // Special: if block.function is ColumnFunction with func=='count'
        if (block.function is ColumnFunction &&
            (block.function as ColumnFunction).func == 'count') {
          final Document c = block.function!.result(
            getItemAtPath,
            buildCombinedQuillConfiguration,
            spreadSheet: spreadSheet,
            visited: Map.from(visited!),
          );
           baseCount += (double.tryParse(c.toPlainText())??0.0).toInt();
        }
      } else {
        final item = spreadSheet == null
            ? getItemAtPath(block.indexPath)
            : getItemAtPath(block.indexPath, spreadSheet);

        if (item is SheetText) {
          raw = item.textEditorConfigurations.controller.document
              .toPlainText()
              .trim();
        } else if (item is SheetTextBox) {
          raw = Document.fromDelta(
                  Delta.fromJson(item.textEditorController as List))
              .toPlainText()
              .trim();
        }
        baseCount++;
      }

      // Normalize to double
      if (raw is num) {
        values.add(raw.toDouble());
      } else if (raw is String) {
        final parsed = double.tryParse(raw);
        if (parsed != null) values.add(parsed);
      } else if (raw is Document) {
        final parsed = double.tryParse(raw.toPlainText().trim());
        if (parsed != null) values.add(parsed);
      }
    }

    return (values,baseCount);
  }

  // ──────────────────────────────
  // BASIC METRICS
  // ──────────────────────────────
  double _sum(List<double> values) => values.fold(0.0, (a, b) => a + b);
  double _product(List<double> values) =>
      values.fold(1.0, (a, b) => a * b);
  double _average(List<double> values) =>
      values.isEmpty ? 0.0 : _sum(values) / values.length;

  double _median(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  double _mode(List<double> values) {
    if (values.isEmpty) return 0.0;
    final freq = <double, int>{};
    for (var v in values) freq[v] = (freq[v] ?? 0) + 1;
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  double _range(List<double> values) =>
      values.isEmpty ? 0.0 : (values.reduce(max) - values.reduce(min));

  double _variance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _average(values);
    return _average(values.map((v) => pow(v - mean, 2).toDouble()).toList());
  }

  double _stdDev(List<double> values) => sqrt(_variance(values));

  double _mad(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _average(values);
    final deviations = values.map((v) => (v - mean).abs()).toList();
    return _average(deviations);
  }

  double _skewness(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _average(values);
    final sd = _stdDev(values);
    if (sd == 0) return 0.0;
    final n = values.length;
    final sumCubed =
        values.fold(0.0, (a, v) => a + pow(v - mean, 3).toDouble());
    return (n / ((n - 1) * (n - 2))) * (sumCubed / pow(sd, 3));
  }

  double _kurtosis(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _average(values);
    final sd = _stdDev(values);
    if (sd == 0) return 0.0;
    final n = values.length;
    final sumFourth =
        values.fold(0.0, (a, v) => a + pow(v - mean, 4).toDouble());
    return (n * (n + 1) / ((n - 1) * (n - 2) * (n - 3))) *
            (sumFourth / pow(sd, 4)) -
        (3 * pow(n - 1, 2) / ((n - 2) * (n - 3)));
  }

  double _percentile(List<double> values, double p) {
    if (values.isEmpty) return 0.0;
    final sorted = [...values]..sort();
    final rank = (p / 100) * (sorted.length - 1);
    final lower = rank.floor();
    final upper = rank.ceil();
    return lower == upper
        ? sorted[lower]
        : sorted[lower] + (sorted[upper] - sorted[lower]) * (rank - lower);
  }

  // ──────────────────────────────
  // STYLING PRESERVATION
  // ──────────────────────────────
  Delta _applyStylingFromOldOps(List<Operation> oldOps, String newText) {
    final newDelta = Delta();
    int written = 0;

    for (final op in oldOps) {
      if (written >= newText.length) break;
      final data = op.data;
      final attrs = op.attributes;
      if (data is String && data.isNotEmpty) {
        final span = data.length;
        final take = (newText.length - written).clamp(0, span);
        final slice = newText.substring(written, written + take);
        if (slice.isNotEmpty) {
          newDelta.insert(slice, attrs);
          written += take;
        }
      }
    }

    if (written < newText.length) {
      newDelta.insert(newText.substring(written));
    }

    // preserve last \n attributes if any
    Map<String, dynamic>? newlineAttrs;
    for (final op in oldOps.reversed) {
      if (op.data is String && (op.data as String).endsWith('\n')) {
        newlineAttrs = op.attributes;
        break;
      }
    }
    newDelta.insert('\n', newlineAttrs);

    return newDelta;
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
        'type': 'unistat',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'resultJson': resultJson,
        'func': func
      };

  factory UniStatFunction.fromMap(Map<String, dynamic> map) => UniStatFunction(
        inputBlocks:  (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        resultJson:  map['resultJson'],
        func: map['func'],
      );
  
  static final Map<String, IconData> availableFunctions = {
    'sum': TablerIcons.sum,
    'count': TablerIcons.tallymarks,
    'average': TablerIcons.math_avg,
    'median': TablerIcons.layout_align_middle,
    'mode': TablerIcons.list_numbers,
    'min': TablerIcons.arrow_down,
    'max': TablerIcons.arrow_up, 
    'range': TablerIcons.arrows_horizontal,
    'range ratio': TablerIcons.slash,
    'product': TablerIcons.x,
    'standard deviation': TablerIcons.chart_donut,
    'variance': TablerIcons.chart_arcs,
    'mean absolute deviation': TablerIcons.wave_saw_tool, // Mean Absolute Deviation
    'skewness': TablerIcons.arrow_curve_right,
    'kurtosis': TablerIcons.chart_bar,
    'geometric mean': TablerIcons.octagon_off,
    'harmonic mean': TablerIcons.circle_letter_h,
    'quadratic mean (rms)': TablerIcons.ripple,
    'sum of cubes': TablerIcons.cube,
    'root mean cube': TablerIcons.cube_off,
    'energy (sum of squares)': TablerIcons.bolt,
    'percentile (p)': TablerIcons.percentage,
    'quartiles (q1,q3)': TablerIcons.layout_list,
  };

  void switchFunc(BuildContext context, Function setStateCallback, Offset position) {
    final menuItems = availableFunctions.entries.map((entry) {
      return MenuItem(
        label: entry.key,
        icon: entry.value,
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.w300,
          color: defaultPalette.primary,
        ),
        hoverColor: defaultPalette.extras[0],
        onSelected: () {
          setStateCallback(() {
            func = entry.key;
          });
        },
      );
    }).toList();

    ContextMenu(
      entries: menuItems,
      boxDecoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: defaultPalette.black,
            blurRadius: 2,
          )
        ],
        color: defaultPalette.extras[0],
        borderRadius: BorderRadius.circular(10),
      ),
      position: position,
    ).show(context);
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
    return UniStatFunction(inputBlocks:inputBlocks, func:func).result(getItemAtPath, buildCombinedQuillConfiguration);
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

@HiveType(typeId: 20)
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
