// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:math';

import 'package:billblaze/util/custom_uid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import 'package:billblaze/colors.dart';
import 'package:billblaze/components/elevated_button.dart';
import 'package:billblaze/home.dart';
import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/layout_model.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:billblaze/screens/layout_designer.dart' as ly;
import 'package:billblaze/util/numeric_input_formatter.dart';
import 'package:uuid/uuid.dart';

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
    bool returnFormatted = false,
  }) {
    throw UnimplementedError('Subclasses must override result()');
  }
  
  List<Widget> buildPrimaryFunctionBlock(
    BuildContext context,
    InputBlock funcBlock,
    List<InputBlock>? selectedInputBlocks,
    double width,
    Function setStateCallBack,
    List<InputBlock> inputBlock,
    int index,
    SheetText item,
    Offset overlayPosition,
    double overlayHeight,
    Function buildCombinedQuillConfiguration,
    Function getItemAtPath,
    Function customStyleBuilder,
    Function uniStatFunctionInputBlocks,
    Function showPositionedTextFieldOverlay,
    {
      bool isSecondary = false,Map<int, FocusNode> extraFocusNodes =const {},
    }

  ) {
    throw UnimplementedError('Subclasses must override result()');
  }

  Widget buildSecondaryFunctionBlock(
    BuildContext context,
    InputBlock funcBlock,
    List<InputBlock>? selectedInputBlocks,
    double width,
    Function setStateCallBack,
    List<InputBlock> inputBlock,
    int index,
    SheetText item,
    Offset overlayPosition,
    double overlayHeight,
    Function buildCombinedQuillConfiguration,
    Function getItemAtPath,
    Function customStyleBuilder,
    Function uniStatFunctionInputBlocks,
    Function showPositionedTextFieldOverlay,
    {
      bool isSecondary = false,Map<int, FocusNode> extraFocusNodes =const {},
    }

    ) {
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
      case 'bistat':
        return BiStatFunction.fromMap(map);
      case 'uidgen':
        return UidGeneratorFunction.fromMap(map);
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

  @HiveField(5)
  Map<String, dynamic>? formatter;

  UniStatFunction({
    required this.inputBlocks,
    this.resultJson = const [],
    required this.func,
    this.formatter,
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
    bool returnFormatted = false,
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
        print(newText);
        break;
      case 'count':
        newText = count.toString();
        break;
      case 'min':
        newText = values.isEmpty
            ? '0'
            : values.reduce(min).toString();
      case 'max':
        newText = values.isEmpty
            ? '0'
            : values.reduce(max).toString();
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
        newText = values.isEmpty
            ? '0'
            : pow(values.fold(1.0, (a, b) => a * b), 1 / values.length).toString();
        break;

      case 'harmean':
      case 'harmonic mean':
        newText = values.isEmpty
            ? '0'
            : (values.length / values.map((x) => 1 / x).reduce((a, b) => a + b)).toString();
        break;

      case 'quadratic mean':
      case 'quadratic mean [rms]':
        newText = values.isEmpty
            ? '0'
            : sqrt(values.map((x) => x * x).reduce((a, b) => a + b) / values.length).toString();
        break;

      case 'sum of cubes':
        newText = values.isEmpty
            ? '0'
            : values.map((x) => x * x * x).reduce((a, b) => a + b).toString();
        break;

      case 'root mean cube':
        newText = values.isEmpty
            ? '0'
            : pow(
                  values.map((x) => x * x * x).reduce((a, b) => a + b) / values.length,
                  1 / 3,
                ).toString();
        break;

      case 'sum of squares':
        newText = values.isEmpty
            ? '0'
            : values.map((x) => x * x).reduce((a, b) => a + b).toString();
        break;

      case 'quartile 1':
        newText = _percentile(values, 25).toString(); // default to median if p not set
        break;
      case 'quartile 2':
        final q1 = _percentile(values, 50);
        newText = '$q1';
        break;
      case 'quartile 3':
        final q3 = _percentile(values, 75);
        newText = '$q3';
        break;
      default:
        newText = 'NaN';
        break;
    }

    // Preserve styling in resultJson
    if(returnFormatted)newText = applyFormatting(newText);
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
      } else {
        values.add(0);
      }
    }

    return (values,baseCount);
  }

  // ──────────────────────────────
  // BASIC METRICS
  // ──────────────────────────────
  double _sum(List<double> values) => values.fold(0.0, (a, b) => a + b);
  double _product(List<double> values) =>
      values.fold(1, (a, b) => a * b);
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
        document: (result(getItemAtPath, buildCombinedQuillConfiguration)), 
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
  
  String applyFormatting(dynamic number){
    final numberFormatter = NumberFormatUtils.fromMap(formatter??NumberFormatUtils.toMap(NumberFormat()));
    var parsed = double.tryParse(number) ?? 0.0;
    return numberFormatter.format(parsed);
  }
  
  @override
  Map<String, dynamic> toMap() => {
        'type': 'unistat',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
        'resultJson': resultJson,
        'func': func,
        'formatter': formatter,
      };

  factory UniStatFunction.fromMap(Map<String, dynamic> map){ 
    print('in UniStatFunctionFromMap: '+map['resultJson'].toString());
    return UniStatFunction(
        inputBlocks:  (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        resultJson:() {
          final result = map['resultJson'];
          if (result is List) {
            return result.map((e) {
              if (e is Map<String, dynamic>) return e;
              if (e is Map) return Map<String, dynamic>.from(e);
              throw Exception('Invalid resultJson entry: $e');
            }).toList();
          }
          return [{'insert': ''}];
        }(),
        func: map['func'],
        formatter: map['formatter'],
      );}
  
  static final Map<String, IconData> availableFunctions = {
    'sum': TablerIcons.sum,
    'count': TablerIcons.tallymarks,
    'average': TablerIcons.math_avg,
    'median': TablerIcons.layout_align_middle,
    'mode': TablerIcons.list_numbers,
    'min': TablerIcons.arrow_down,
    'max': TablerIcons.arrow_up, 
    'range': TablerIcons.arrows_horizontal,
    'range ratio': TablerIcons.grid_goldenratio,
    'product': TablerIcons.x,
    'standard deviation': TablerIcons.chart_sankey,
    'variance': TablerIcons.chart_arcs,
    'mean absolute deviation': TablerIcons.wave_saw_tool, // Mean Absolute Deviation
    'skewness': TablerIcons.arrow_curve_right,
    'kurtosis': TablerIcons.chart_bar,
    'geometric mean': TablerIcons.circle_letter_g,
    'harmonic mean': TablerIcons.circle_letter_h,
    'quadratic mean': TablerIcons.circle_letter_q,
    'sum of cubes': TablerIcons.cube_plus,
    'root mean cube': TablerIcons.cube_unfolded,
    'sum of squares': TablerIcons.bolt,
    'quartile 1': TablerIcons.number_1_small,
    'quartile 2': TablerIcons.number_2_small,
    'quartile 3': TablerIcons.number_3_small,
  };

  static const Map<String, List<String>> functionCategories = {
  'Basic Statistics': [
    'sum',
    'count',
    'product',
    'average',
    'median',
    'mode',
    'min',
    'max',
  ],
  'Dispersion Measures': [
    'range',
    'range ratio',
    'standard deviation',
    'variance',
    'mean absolute deviation',
    'quartile 1',
    'quartile 2',
    'quartile 3'
  ],
  'Shape Descriptors': [
    'skewness',
    'kurtosis',
  ],
  'Means': [
    'geometric mean',
    'harmonic mean',
    'quadratic mean',
    'root mean cube',
  ],
  'Transform Sums': [
    'sum of squares',
    'sum of cubes',
  ],
};


  void switchFunc(BuildContext context, Function setStateCallback, Offset position) {
    final entries = UniStatFunction.functionCategories.entries.map((category) {
    return MenuItem.submenu(
      label: category.key,
      style: GoogleFonts.lexend(color: defaultPalette.primary),
      hoverColor: defaultPalette.extras[0],
      unfocusedColor: defaultPalette.primary.withOpacity(0.05),
      items: category.value.map((funcName) {
        final icon = UniStatFunction.availableFunctions[funcName];
        return MenuItem(
          label: funcName,
          icon: icon,
          style: GoogleFonts.lexend(color: defaultPalette.primary),
          hoverColor: defaultPalette.extras[0],
          unfocusedColor: defaultPalette.primary.withOpacity(0.05),
          onSelected: () {
            setStateCallback(() {
              func = funcName;
            });
          },
        );
      }).toList(),
    );
  }).toList();

  ContextMenu(
    entries: entries,
    boxDecoration: BoxDecoration(
      color: defaultPalette.extras[0],
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: defaultPalette.black, blurRadius: 2)],
    ),
    position: position, // Update with actual cursor pos
  ).show(context);
  }
  

  UniStatFunction copyWith({
    List<InputBlock>? inputBlocks,
    List<Map<String, dynamic>>? resultJson,
    String? func,
    Map<String, dynamic>? formatter,
  }) {
    return UniStatFunction(
      inputBlocks: inputBlocks ?? this.inputBlocks,
      resultJson: resultJson ?? this.resultJson,
      func: func ?? this.func,
      formatter: formatter ?? this.formatter,
    );
  }
}

@HiveType(typeId:19)
class ColumnFunction extends SheetFunction with QuillFormattingMixin {
  @HiveField(2)
  List<InputBlock> inputBlocks;

  @HiveField(3)
  String func;

  @HiveField(4)
  String axisLabel;

  @HiveField(5)
  List<Map<String, dynamic>> resultJson =[];

  @HiveField(6)
  bool lockMode = false;

  ColumnFunction({
    required this.inputBlocks, 
    required this.func, 
    required this.axisLabel,
    this.resultJson = const [],
    this.lockMode = false
    }) : super(0, 'column');

  @override
  dynamic result(Function getItemAtPath,
   Function buildCombinedQuillConfiguration,
   {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
    bool returnFormatted = false,
  }) {
    return UniStatFunction(inputBlocks:inputBlocks, func:func, resultJson: resultJson).result(getItemAtPath, buildCombinedQuillConfiguration, returnFormatted: returnFormatted);
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

  factory ColumnFunction.fromMap(Map<String, dynamic> map) {
    print('in ColumnFunctionFromMap: '+map['resultJson'].toString());
    return ColumnFunction(
      inputBlocks: 
        (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        func:
            map['func'],
        axisLabel: map['axisLabel'],
        resultJson: () {
          final result = map['resultJson'];
          if (result is List) {
            return result.map((e) {
              if (e is Map<String, dynamic>) return e;
              if (e is Map) return Map<String, dynamic>.from(e);
              throw Exception('Invalid resultJson entry: $e');
            }).toList();
          }
          return [{'insert': ''}];
        }(),

      );}

    void switchFunc(BuildContext context, Function setStateCallback, Offset position) {
    final entries = UniStatFunction.functionCategories.entries.map((category) {
    return MenuItem.submenu(
      label: category.key,
      style: GoogleFonts.lexend(color: defaultPalette.primary),
      hoverColor: defaultPalette.extras[0],
      unfocusedColor: defaultPalette.primary.withOpacity(0.05),
      items: category.value.map((funcName) {
        final icon = UniStatFunction.availableFunctions[funcName];
        return MenuItem(
          label: funcName,
          icon: icon,
          style: GoogleFonts.lexend(color: defaultPalette.primary),
          hoverColor: defaultPalette.extras[0],
          unfocusedColor: defaultPalette.primary.withOpacity(0.05),
          onSelected: () {
            setStateCallback(() {
              func = funcName;
            });
          },
        );
      }).toList(),
    );
  }).toList();

  ContextMenu(
    entries: entries,
    boxDecoration: BoxDecoration(
      color: defaultPalette.extras[0],
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: defaultPalette.black, blurRadius: 2)],
    ),
    position: position, // Update with actual cursor pos
  ).show(context);
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
  result(Function getItemAtPath, Function buildCombinedQuillConfiguration, {List<SheetListBox>? spreadSheet,Map<List<InputBlock>, int>? visited,bool returnFormatted = false,}) {
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

  factory InputBlockFunction.fromMap(Map<String, dynamic> map) {
    print('in InputBlockFunctionFromMap: '+map['label']);
    return InputBlockFunction(
        inputBlocks: (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        label: map['label'],
        
      );}

}

@HiveType(typeId: 21)
class BiStatFunction extends SheetFunction with QuillFormattingMixin {
  @HiveField(2)
  List<InputBlock> inputBlocksX;

  @HiveField(3)
  List<InputBlock> inputBlocksY;

  @HiveField(4)
  List<Map<String, dynamic>> resultJson = [];

  @HiveField(5)
  String func;

  bool isX = true;

  BiStatFunction({
    required this.inputBlocksX,
    required this.inputBlocksY,
    this.resultJson = const [],
    required this.func,
    this.isX = true,
  }) : super(1, 'bistat');

  @override
  dynamic result(
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration, {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
    bool returnFormatted = false,
  }) {
    visited ??= {};
    visited[inputBlocksX] = (visited[inputBlocksX] ?? 0) + 1;
    visited[inputBlocksY] = (visited[inputBlocksY] ?? 0) + 1;

    if (visited[inputBlocksX]! > 50 || visited[inputBlocksY]! > 50) {
      return 'recursion detected';
    }

    final (valuesX, countX) = _collectValues(inputBlocksX, getItemAtPath, buildCombinedQuillConfiguration,
        spreadSheet: spreadSheet, visited: visited);
    final (valuesY, countY) = _collectValues(inputBlocksY, getItemAtPath, buildCombinedQuillConfiguration,
        spreadSheet: spreadSheet, visited: visited);

    String newText;

    switch (func.toLowerCase()) {
      case 'difference':
        // element-wise X - Y
        final sumX = valuesX.fold<double>(0, (a, b) => a + b);
        final sumY = valuesY.fold<double>(0, (a, b) => a + b);
        newText = (sumX-sumY).toString();
        break;
      case 'percentage':
        final sumX = valuesX.fold<double>(0, (a, b) => a + b);
        final sumY = valuesY.fold<double>(0, (a, b) => a + b);

        final result = sumX * (sumY / 100);
        newText = result.toStringAsFixed(2);
        break;
      case 'proportionality':
        final sumX = valuesX.fold<double>(0, (a, b) => a + b);
        final sumY = valuesY.fold<double>(0, (a, b) => a + b);
        final result = sumY == 0 ? 0 : (sumX / sumY) * 100;
        newText = result.toStringAsFixed(2);
        break;
      case 'change percentage':
        newText = _zip(valuesX, valuesY)
            .map((pair) {
              final old = pair.$2;
              final now = pair.$1;
              if (old == 0) return 'NaN';
              final change = ((now - old) / old) * 100;
              return change.toStringAsFixed(2) + '%';
            })
            .join(', ');
        break;
      case 'weighted percentage':
        if (valuesX.length != valuesY.length) {
          newText = 'Error: Mismatched lengths';
          break;
        }

        double weightedSum = 0;
        double weightTotal = 0;

        for (int i = 0; i < valuesX.length; i++) {
          final x = valuesX[i];
          final w = valuesY[i];
          weightedSum += x * w;
          weightTotal += w;
        }

        final result = weightTotal == 0 ? 0 : (weightedSum / weightTotal) * 100;
        newText = result.toStringAsFixed(2) + '%';
        break;


      case 'ratio':
        // element-wise "X:Y"
        newText = _zip(valuesX, valuesY)
            .map((pair) => '${pair.$1}:${pair.$2}')
            .join(', ');
        break;
      case 'growth rate':
        // (Y - X) / X * 100
        newText = _zip(valuesX, valuesY)
            .map((pair) => pair.$1 == 0 ? 'NaN' : (((pair.$2 - pair.$1) / pair.$1) * 100).toStringAsFixed(2) + '%')
            .join(', ');
        break;
      case 'exponent':
      case 'power':
        // X ^ Y
        newText = _zip(valuesX, valuesY)
            .map((pair) => pow(pair.$1, pair.$2).toString())
            .join(', ');
        break;
      case 'log ratio':
        // log(Y/X)
        newText = _zip(valuesX, valuesY)
            .map((pair) => pair.$1 == 0 ? 'NaN' : (log(pair.$2 / pair.$1)).toStringAsFixed(4))
            .join(', ');
        break;
      case 'weighted average':
        // sum(X*Y)/sum(Y)
        final numerator = _zip(valuesX, valuesY).fold(0.0, (a, pair) => a + pair.$1 * pair.$2);
        final denominator = valuesY.fold(0.0, (a, b) => a + b);
        newText = denominator == 0 ? 'NaN' : (numerator / denominator).toString();
        break;
      default:
        newText = 'NaN';
        break;
    }

    // Preserve styling
    final oldDelta = Delta.fromJson(resultJson);
    final oldOps = oldDelta.toList();
    final newDelta = _applyStylingFromOldOps(oldOps, newText);

    final newJson = newDelta.toJson();
    if (newJson != resultJson) {
      resultJson = newJson;
    }

    return Document.fromDelta(newDelta);
  }

  (List<double>, int) _collectValues(
    List<InputBlock> blocks,
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration, {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
  }) {
    final values = <double>[];
    int baseCount = 0;

    for (final block in blocks) {
      dynamic raw;

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
            visited: Map.from(visited??{}),
            returnFormatted: false
          );
          // print('RAWW: $raw');
        }
        baseCount++;
      } else {
        final item = spreadSheet == null
            ? getItemAtPath(block.indexPath)
            : getItemAtPath(block.indexPath, spreadSheet);

        if (item is SheetText) {
          raw = item.textEditorConfigurations.controller.document
              .toPlainText();
          
        } else if (item is SheetTextBox) {
          raw = Document.fromDelta(
                  Delta.fromJson(item.textEditorController as List))
              .toPlainText()
              .trim();
        }
        baseCount++;
      }

      // Normalize
      if (raw is num) {
        values.add(raw.toDouble());
      } else if (raw is String) {
        final parsed = double.tryParse(raw);
        if (parsed != null) values.add(parsed);
      } else if (raw is Document) {
        // print('RAWW: ${raw.toPlainText()}');
        final parsed = double.tryParse(raw.toPlainText().trim());
        if (parsed != null) values.add(parsed);
        
        // print('PPAWW: $parsed');
      } else {
        values.add(0);
      }
    }

    return (values, baseCount);
  }

  List<(double, double)> _zip(List<double> xs, List<double> ys) {
    final length = min(xs.length, ys.length);
    return List.generate(length, (i) => (xs[i], ys[i]));
  }

  Delta _applyStylingFromOldOps(List<Operation> oldOps, String newText) {
    final newDelta = Delta();
    int written = 0;

    // Find last non-newline attrs
    Map<String, dynamic>? lastCharAttrs;
    for (final op in oldOps.reversed) {
      final data = op.data;
      if (data is String && data != '\n') {
        lastCharAttrs = op.attributes;
        break;
      }
    }

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
      newDelta.insert(newText.substring(written), lastCharAttrs);
    }

    // Preserve last newline attributes if any
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
  
  static final Map<String, IconData> availableFunctions = {
    'difference': TablerIcons.minus,
    'percentage': TablerIcons.percentage,
    'ratio': TablerIcons.slash,
    'growth rate': TablerIcons.trending_up,
    'exponent': TablerIcons.superscript,
    'log ratio': TablerIcons.math_function,
    'weighted average': TablerIcons.weight,
    'proportionality':TablerIcons.protocol,
    'change percentage': TablerIcons.switch_3,
    'weighted percentage': TablerIcons.scale_outline,
  };

  static const Map<String, List<String>> functionCategories = {
    'Comparison': ['difference', 'percentage', 'ratio', 'growth rate'],
    'Transformations': ['exponent', 'log ratio'],
    'Aggregates': ['weighted average'],
  };

  @override
  Map<String, dynamic> toMap() => {
        'type': 'bistat',
        'returnType': returnType,
        'name': name,
        'inputBlocksX': inputBlocksX.map((e) => e.toMap()).toList(),
        'inputBlocksY': inputBlocksY.map((e) => e.toMap()).toList(),
        'resultJson': resultJson,
        'func': func,
      };

  factory BiStatFunction.fromMap(Map<String, dynamic> map) {
    print('in BiStatFunctionFromMap: '+map['resultJson'].toString());
    return BiStatFunction(
        inputBlocksX: (map['inputBlocksX'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        inputBlocksY: (map['inputBlocksY'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        resultJson:() {
          final result = map['resultJson'];
          if (result is List) {
            return result.map((e) {
              if (e is Map<String, dynamic>) return e;
              if (e is Map) return Map<String, dynamic>.from(e);
              throw Exception('Invalid resultJson entry: $e');
            }).toList();
          }
          return [{'insert': ''}];
        }(),
        func: map['func'],
      );}

  @override
  List<Widget> buildPrimaryFunctionBlock(
    BuildContext context,
    InputBlock funcBlock,
    List<InputBlock>? selectedInputBlocks,
    double width,
    Function setStateCallBack,
    List<InputBlock> inputBlock,
    int index,
    SheetText item,
    Offset overlayPosition,
    double overlayHeight,
    Function buildCombinedQuillConfiguration,
    Function getItemAtPath,
    Function customStyleBuilder,
    Function uniStatFunctionInputBlocks,
    Function showPositionedTextFieldOverlay,
    {
      bool isSecondary = false,Map<int, FocusNode> extraFocusNodes =const {},
    }

    ){
      final (valuesX, countX) = _collectValues(inputBlocksX, getItemAtPath, buildCombinedQuillConfiguration,
        );
    final (valuesY, countY) = _collectValues(inputBlocksY, getItemAtPath, buildCombinedQuillConfiguration,
        );
    return [
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedMeshGradient(
              colors: [
                  // defaultPalette.extras[0],
                  defaultPalette.primary,
                  defaultPalette.primary,
                  defaultPalette.primary,
                  selectedInputBlocks ==inputBlocksX? defaultPalette.extras[0]: defaultPalette.primary,
                ],
              options: AnimatedMeshGradientOptions(
                  amplitude: 5,
                  grain: 0.1,
                  frequency: 15,
                  
                ),
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8).copyWith(
                  bottomRight: Radius.circular(funcBlock.isExpanded?0:8),
                  bottomLeft: Radius.circular(funcBlock.isExpanded?0:8) 
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 15,),
                  //the title of function
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          func,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            height: 1,
                            color: defaultPalette.extras[0],
                          ),
                        ),
                      ),
                      const SizedBox(width:8),
                    ],
                  ),
                  //sum/count and index

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2),
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: defaultPalette.extras[0],
                          ),
                          child: Row(
                          children: [
                            const SizedBox(width: 3),
                            Icon(BiStatFunction.availableFunctions[func], color:defaultPalette.primary, size:14),
                            const SizedBox(width: 3),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.lexend(
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: defaultPalette.extras[0],
                                  ),
                                  children: [
                                    // TextSpan(text: ' sum: ',style: TextStyle(color:Color(0xffB388EB)),),
                                    TextSpan(
                                      text: getConfigurations(getItemAtPath,buildCombinedQuillConfiguration, setStateCallBack, customStyleBuilder).controller.document.toPlainText(),
                                      style: TextStyle(color:defaultPalette.primary),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.lexend(
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: defaultPalette.extras[0],
                                  ),
                                  children: [
                                    TextSpan(text: 'xInx: ',style: TextStyle(color: Color(0xff3993DD)),),
                                    TextSpan(
                                      text: '0-${(inputBlocksX.length - 1).clamp(0, double.infinity)}',
                                      style: TextStyle(color:defaultPalette.primary),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                             Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.lexend(
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: defaultPalette.extras[0],
                                  ),
                                  children: [
                                    TextSpan(text: 'yInx: ',style: TextStyle(color: Color(0xff3993DD)),),
                                    TextSpan(
                                      text: '0-${(inputBlocksY.length - 1).clamp(0, double.infinity)}',
                                      style: TextStyle(color:defaultPalette.primary),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 3),
                          ],
                        ),
                        ),
                      ),
                    
                    ],
                  ),
                  
                  if(funcBlock.isExpanded)
                  ...[SizedBox(height: 5,),
                  //the label tiles for folded vsalues of x and y
                  Container(
                    width: width,
                    decoration:BoxDecoration(
                      color:defaultPalette.transparent,
                      // border:Border.all()
                    ),
                    //reorderable for functioninputblockchildren
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //num and sumfold of valuesX
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                 children: [
                                   Expanded(
                                     child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: double.tryParse(valuesX.fold<double>(0, (a, b) => a + b).toString()) ==null? Color(0xffFF7477) :defaultPalette.secondary,
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal:4),
                                      margin: EdgeInsets.all(4).copyWith(bottom: 4),
                                      child: Text(
                                        valuesX.fold<double>(0, (a, b) => a + b).toString(),
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lexend(
                                            letterSpacing: -1,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: defaultPalette.extras[0],
                                          ),
                                        ),
                                    ),
                                   ),
                                 ],
                               ),
                               Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setStateCallBack((){
                                          isX = true;
                                        });
                                      },
                                      child: Text('  X',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lexend(
                                        letterSpacing: -1,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 1,
                                        color:isX? defaultPalette.tertiary: defaultPalette.extras[0],
                                      ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                            
                            ],
                          ),
                        ),
                        //% icon in between
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Icon(TablerIcons.percentage,size:15),
                        ),
                        //percent and sumfold of valuesY
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                 children: [
                                   Expanded(
                                     child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: double.tryParse(valuesY.fold<double>(0, (a, b) => a + b).toString()) ==null? Color(0xffFF7477) :defaultPalette.secondary,
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal:4),
                                      margin: EdgeInsets.all(4).copyWith(bottom: 4),
                                      child: Text(
                                          valuesY.fold<double>(0, (a, b) => a + b).toString(),
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lexend(
                                            letterSpacing: -1,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: defaultPalette.extras[0],
                                        ),
                                      ),
                                    ),
                                   ),
                                 ],
                               ),
                               Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setStateCallBack((){
                                          isX = false;
                                        });
                                      },
                                      child: Text('Y',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lexend(
                                        letterSpacing: -1,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 1,
                                        color: !isX? defaultPalette.tertiary:defaultPalette.extras[0],
                                      ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width:5)
                                ],
                              ),
                            
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  //the reorderable tiles for x and y 
                  Container(
                    width: width,
                    decoration:BoxDecoration(
                      color:defaultPalette.transparent,
                      // border:Border.all()
                      borderRadius: BorderRadius.circular(10)
                    ),
                    // padding: EdgeInsets.symmetric(horizontal: 3),
                    //reorderable for functioninputblockchildren
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //reorderable for X
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8).copyWith(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                            ),
                            child: Column(
                              children: [
                                ScrollConfiguration(
                                  behavior: ScrollBehavior().copyWith(scrollbars: false),
                                  child: DynMouseScroll(
                                    durationMS: 500,
                                    scrollSpeed: 1,
                                    builder: (context, controller, physics) {
                                      return ReorderableListView.builder(
                                        shrinkWrap: true,
                                        buildDefaultDragHandles: false,
                                        scrollDirection: Axis.vertical,
                                        scrollController:controller,
                                        physics:physics,
                                        itemCount:isX? inputBlocksX.length:inputBlocksY.length,
                                        onReorder: (oldIndex, newIndex) {
                                          setStateCallBack(() {
                                            if (newIndex > oldIndex) {
                                              newIndex -= 1;
                                            }
                                            final sheetItem = (isX? inputBlocksX: inputBlocksY).removeAt(oldIndex);
                                            // buildlistw
                                            (isX? inputBlocksX:inputBlocksY).insert(newIndex, sheetItem);
                                          });
                                        },
                                        proxyDecorator: (child, index, animation) {
                                          return Container(child: child); },
                                        itemBuilder: (context, inx) {
                                            return uniStatFunctionInputBlocks((isX? inputBlocksX: inputBlocksY), inx, parent:UniStatFunction(inputBlocks: (isX? inputBlocksX: inputBlocksY), func: 'sum'), );
                                            
                                        });
                                      }
                                    ),
                                  ),
                                //add field or function inside the expansion of a function tile
                                Material(
                                  color: defaultPalette.primary,
                                  child: InkWell(
                                    hoverColor: defaultPalette.primary.withOpacity(0.08),
                                    splashColor: defaultPalette.primary.withOpacity(0.08),
                                    highlightColor: defaultPalette.primary.withOpacity(0.08),
                                    onTap: () {
                                    showPositionedTextFieldOverlay(
                                    context:context,
                                    position:overlayPosition,
                                    width: width,
                                    inputBlocks: (isX? inputBlocksX: inputBlocksY),
                                    height: overlayHeight,
                                    );
                                  },
                                    child: Container(
                                      width:width,
                                      child: Icon(
                                      TablerIcons.plus,
                                      size: 18,
                                      color:defaultPalette.extras[0]
                                    ),
                                    ),
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                  // SizedBox(height: 4,),
                  ],
                  
                  ],
              ),
            ),
          ),
        ),
      ),
      ElevatedLayerButton(
        
        isTapped: funcBlock.isExpanded,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(5),
          topLeft: Radius.circular(5),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        animationDuration: const Duration(milliseconds: 100),
        animationCurve: Curves.ease,
        topDecoration: BoxDecoration(
          color: defaultPalette.primary,
          border: Border.all(color: defaultPalette.extras[0]),
        ),
        topLayerChild: Row(
          children: [
            const SizedBox(width: 10),
            Icon(TablerIcons.medical_cross_filled, size: 13, color: defaultPalette.extras[0]),
            Expanded(
              child: Text(
                ' edit',
                maxLines: 1,
                style: GoogleFonts.bungee(
                  fontSize: 12,
                  color: defaultPalette.extras[0],
                  // letterSpacing: -1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        baseDecoration: BoxDecoration(
          color: defaultPalette.extras[0],
          border: Border.all(color: defaultPalette.extras[0]),
        ),
        depth: 2,
        subfac: 2,
        buttonHeight: 24,
        buttonWidth: 80,
        onClick: () {
          setStateCallBack(() {
            // inputBlockExpansionList[index] = !// inputBlockExpansionList[index];
            inputBlock[index].isExpanded =!inputBlock[index].isExpanded;
          });
        },
      ),
      Positioned(
        left:81,
        child: ElevatedLayerButton(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              topLeft: Radius.circular(5),
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            animationDuration: const Duration(milliseconds: 100),
            animationCurve: Curves.ease,
            topDecoration: BoxDecoration(
              color: defaultPalette.secondary,
              border: Border.all(color: defaultPalette.extras[0]),
            ),
            topLayerChild: Row(
              children: [
                const SizedBox(width: 2),
                Icon(funcBlock.useConst?TablerIcons.cursor_text:TablerIcons.x, size: 12, color: defaultPalette.extras[0]),
                
              ],
            ),
            baseDecoration: BoxDecoration(
              color: defaultPalette.extras[0],
              border: Border.all(color: defaultPalette.extras[0]),
            ),
            depth: 2,
            subfac: 2,
            buttonHeight: 24,
            buttonWidth: 20,
            onClick: () {
              setStateCallBack(() {
              inputBlock.removeAt(index);
              // inputBlockExpansionList.removeAt(index);
            });
            },
          ),
      ),
    
    ];
                      
  }
  
  @override
  Widget buildSecondaryFunctionBlock(
    BuildContext context,
    InputBlock funcBlock,
    List<InputBlock>? selectedInputBlocks,
    double width,
    Function setStateCallBack,
    List<InputBlock> inputBlock,
    int index,
    SheetText item,
    Offset overlayPosition,
    double overlayHeight,
    Function buildCombinedQuillConfiguration,
    Function getItemAtPath,
    Function customStyleBuilder,
    Function uniStatFunctionInputBlocks,
    Function showPositionedTextFieldOverlay,
    {
      bool isSecondary = false,Map<int, FocusNode> extraFocusNodes =const {}
    }

    ){
      final (valuesX, countX) = _collectValues(inputBlocksX, getItemAtPath, buildCombinedQuillConfiguration,
        );
    final (valuesY, countY) = _collectValues(inputBlocksY, getItemAtPath, buildCombinedQuillConfiguration,
        );
    return 
      AnimatedMeshGradient(
          colors: [
              // defaultPalette.extras[0],
              defaultPalette.primary,
              defaultPalette.primary,
              defaultPalette.primary,
              selectedInputBlocks ==inputBlocksX? defaultPalette.extras[0]: defaultPalette.primary,
            ],
          options: AnimatedMeshGradientOptions(
              amplitude: 5,
              grain: 0.1,
              frequency: 15,
              
            ),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8).copyWith(
              bottomRight: Radius.circular(funcBlock.isExpanded?0:8),
              bottomLeft: Radius.circular(funcBlock.isExpanded?0:8) 
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 5,),
              //the title of function
              Row(
                children: [
                   const SizedBox(width: 4),
                  Text(
                    index.toString(),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexend(
                      letterSpacing: -1,
                      fontWeight: FontWeight.w500,
                      fontSize:18,
                      color: defaultPalette.extras[0],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      func,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        height: 1,
                        color: defaultPalette.extras[0],
                      ),
                    ),
                  ),
                  const SizedBox(width:8),
                ],
              ),
              //sum/count and index
            
              Row(
                children: [
                   const SizedBox(width: 2),
                  ElevatedLayerButton(
                  isTapped: funcBlock.isExpanded,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5),
                    topLeft: Radius.circular(5),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  animationDuration: const Duration(milliseconds: 100),
                  animationCurve: Curves.ease,
                  topDecoration: BoxDecoration(
                    color: defaultPalette.primary,
                    border: Border.all(color: defaultPalette.extras[0]),
                  ),
                  topLayerChild: Row(
                    children: [
                      Expanded(child: Icon(TablerIcons.medical_cross_filled, size: 13, color: defaultPalette.extras[0])),
                    ],
                  ),
                  baseDecoration: BoxDecoration(
                    color: defaultPalette.extras[0],
                    border: Border.all(color: defaultPalette.extras[0]),
                  ),
                  depth: 2,
                  subfac: 2,
                  buttonHeight: 24,
                  buttonWidth: 20,
                  onClick: () {
                    setStateCallBack(() {
                      // inputBlockExpansionList[index] = !// inputBlockExpansionList[index];
                      inputBlock[index].isExpanded =!inputBlock[index].isExpanded;
                    });
                  },
                ),
                   const SizedBox(width: 2),
                  ElevatedLayerButton(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5),
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      animationDuration: const Duration(milliseconds: 100),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: defaultPalette.secondary,
                        border: Border.all(color: defaultPalette.extras[0]),
                      ),
                      topLayerChild: Row(
                        children: [
                          const SizedBox(width: 2),
                          Icon(funcBlock.useConst?TablerIcons.cursor_text:TablerIcons.x, size: 12, color: defaultPalette.extras[0]),
                          
                        ],
                      ),
                      baseDecoration: BoxDecoration(
                        color: defaultPalette.extras[0],
                        border: Border.all(color: defaultPalette.extras[0]),
                      ),
                      depth: 2,
                      subfac: 2,
                      buttonHeight: 24,
                      buttonWidth: 20,
                      onClick: () {
                        setStateCallBack(() {
                        inputBlock.removeAt(index);
                        // inputBlockExpansionList.removeAt(index);
                      });
                      },
                    ),
          
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(2),
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: defaultPalette.extras[0],
                      ),
                      child: Row(
                      children: [
                        const SizedBox(width: 3),
                        Icon(BiStatFunction.availableFunctions[func], color:defaultPalette.primary, size:14),
                        const SizedBox(width: 3),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.lexend(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: defaultPalette.extras[0],
                              ),
                              children: [
                                // TextSpan(text: ' sum: ',style: TextStyle(color:Color(0xffB388EB)),),
                                TextSpan(
                                  text: getConfigurations(getItemAtPath,buildCombinedQuillConfiguration, setStateCallBack, customStyleBuilder).controller.document.toPlainText(),
                                  style: TextStyle(color:defaultPalette.primary),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.lexend(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: defaultPalette.extras[0],
                              ),
                              children: [
                                TextSpan(text: 'xInx: ',style: TextStyle(color: Color(0xff3993DD)),),
                                TextSpan(
                                  text: '0-${(inputBlocksX.length - 1).clamp(0, double.infinity)}',
                                  style: TextStyle(color:defaultPalette.primary),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                         Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.lexend(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: defaultPalette.extras[0],
                              ),
                              children: [
                                TextSpan(text: 'yInx: ',style: TextStyle(color: Color(0xff3993DD)),),
                                TextSpan(
                                  text: '0-${(inputBlocksY.length - 1).clamp(0, double.infinity)}',
                                  style: TextStyle(color:defaultPalette.primary),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 3),
                      ],
                    ),
                    ),
                  ),
                
                ],
              ),
              SizedBox(height: 5,),
              if(funcBlock.isExpanded)
              ...[
              //the label tiles for folded vsalues of x and y
              Container(
                width: width,
                decoration:BoxDecoration(
                  color:defaultPalette.transparent,
                  // border:Border.all()
                ),
                //reorderable for functioninputblockchildren
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //num and sumfold of valuesX
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                             children: [
                               Expanded(
                                 child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: double.tryParse(valuesX.fold<double>(0, (a, b) => a + b).toString()) ==null? Color(0xffFF7477) :defaultPalette.secondary,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal:4),
                                  margin: EdgeInsets.all(4).copyWith(bottom: 4),
                                  child: Text(
                                    valuesX.fold<double>(0, (a, b) => a + b).toString(),
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lexend(
                                        letterSpacing: -1,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: defaultPalette.extras[0],
                                      ),
                                    ),
                                ),
                               ),
                             ],
                           ),
                           Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateCallBack((){
                                      isX = true;
                                    });
                                  },
                                  child: Text('  X',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lexend(
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1,
                                    color:isX? defaultPalette.tertiary: defaultPalette.extras[0],
                                  ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                        
                        ],
                      ),
                    ),
                    //% icon in between
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Icon(TablerIcons.percentage,size:15),
                    ),
                    //percent and sumfold of valuesY
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                             children: [
                               Expanded(
                                 child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: double.tryParse(valuesY.fold<double>(0, (a, b) => a + b).toString()) ==null? Color(0xffFF7477) :defaultPalette.secondary,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal:4),
                                  margin: EdgeInsets.all(4).copyWith(bottom: 4),
                                  child: Text(
                                      valuesY.fold<double>(0, (a, b) => a + b).toString(),
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lexend(
                                        letterSpacing: -1,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: defaultPalette.extras[0],
                                    ),
                                  ),
                                ),
                               ),
                             ],
                           ),
                           Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateCallBack((){
                                      isX = false;
                                    });
                                  },
                                  child: Text('Y',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lexend(
                                    letterSpacing: -1,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1,
                                    color: !isX? defaultPalette.tertiary:defaultPalette.extras[0],
                                  ),
                                  ),
                                ),
                              ),
                              SizedBox(width:5)
                            ],
                          ),
                        
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5,),
              //the reorderable tiles for x and y 
              Container(
                width: width,
                decoration:BoxDecoration(
                  color:defaultPalette.transparent,
                  // border:Border.all()
                  borderRadius: BorderRadius.circular(10)
                ),
                // padding: EdgeInsets.symmetric(horizontal: 3),
                //reorderable for functioninputblockchildren
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //reorderable for X
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8).copyWith(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                        child: Column(
                          children: [
                            ScrollConfiguration(
                              behavior: ScrollBehavior().copyWith(scrollbars: false),
                              child: DynMouseScroll(
                                durationMS: 500,
                                scrollSpeed: 1,
                                builder: (context, controller, physics) {
                                  return ReorderableListView.builder(
                                    shrinkWrap: true,
                                    buildDefaultDragHandles: false,
                                    scrollDirection: Axis.vertical,
                                    scrollController:controller,
                                    physics:physics,
                                    itemCount:isX? inputBlocksX.length:inputBlocksY.length,
                                    onReorder: (oldIndex, newIndex) {
                                      setStateCallBack(() {
                                        if (newIndex > oldIndex) {
                                          newIndex -= 1;
                                        }
                                        final sheetItem = (isX? inputBlocksX: inputBlocksY).removeAt(oldIndex);
                                        // buildlistw
                                        (isX? inputBlocksX:inputBlocksY).insert(newIndex, sheetItem);
                                      });
                                    },
                                    proxyDecorator: (child, index, animation) {
                                      return Container(child: child); },
                                    itemBuilder: (context, inx) {
                                        return uniStatFunctionInputBlocks((isX? inputBlocksX: inputBlocksY), inx, parent:UniStatFunction(inputBlocks: (isX? inputBlocksX: inputBlocksY), func: 'sum'), );
                                        
                                    });
                                  }
                                ),
                              ),
                            //add field or function inside the expansion of a function tile
                            Material(
                              color: defaultPalette.primary,
                              child: InkWell(
                                hoverColor: defaultPalette.primary.withOpacity(0.08),
                                splashColor: defaultPalette.primary.withOpacity(0.08),
                                highlightColor: defaultPalette.primary.withOpacity(0.08),
                                onTap: () {
                                showPositionedTextFieldOverlay(
                                context:context,
                                position:overlayPosition,
                                width: width,
                                inputBlocks: (isX? inputBlocksX: inputBlocksY),
                                height: overlayHeight,
                                );
                              },
                                child: Container(
                                  width:width,
                                  child: Icon(
                                  TablerIcons.plus,
                                  size: 18,
                                  color:defaultPalette.extras[0]
                                ),
                                ),
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ),
                   
                  ],
                ),
              ),
              // SizedBox(height: 4,),
              ],
              
              ],
          ),
        ),
      );
                      
  }
  


  BiStatFunction copyWith({
    List<InputBlock>? inputBlocksX,
    List<InputBlock>? inputBlocksY,
    List<Map<String, dynamic>>? resultJson,
    String? func,
    bool? isX,
  }) {
    return BiStatFunction(
      inputBlocksX: inputBlocksX ?? this.inputBlocksX,
      inputBlocksY: inputBlocksY ?? this.inputBlocksY,
      resultJson: resultJson ?? this.resultJson,
      func: func ?? this.func,
      isX: isX ?? this.isX,
    );
  }
}

@HiveType(typeId: 22)
class UidGeneratorFunction extends SheetFunction with QuillFormattingMixin {
  @HiveField(2)
  String template;

  @HiveField(3)
  List<Map<String, dynamic>> resultJson = [];
  
  @HiveField(4)
  String idKey;

  @HiveField(5)
  String func;

  @HiveField(6)
  DateTime? dateTime;

  UidGeneratorFunction({
    required this.template,
    this.resultJson = const [],
    this.idKey = '00',
    this.func = 'uidGenerator',
    required this.dateTime
  }):super(1, 'uidgen');

  

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': 'uidgen',
      'returnType': returnType,
      'template': template,
      'resultJson': resultJson,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory UidGeneratorFunction.fromMap(Map<String, dynamic> map) {
    return UidGeneratorFunction(
      template: map['template'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(((map['dateTime'])?? DateTime.now().millisecondsSinceEpoch)as int),
      resultJson:() {
          final result = map['resultJson'];
          if (result is List) {
            return result.map((e) {
              if (e is Map<String, dynamic>) return e;
              if (e is Map) return Map<String, dynamic>.from(e);
              throw Exception('Invalid resultJson entry: $e');
            }).toList();
          }
          return [{'insert': ''}];
        }(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UidGeneratorFunction.fromJson(String source) => UidGeneratorFunction.fromMap(json.decode(source) as Map<String, dynamic>);


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
        document: (result(getItemAtPath, buildCombinedQuillConfiguration)), 
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
  
  void showOpsFormatMenu(BuildContext context, Offset position, Function setStateCallback, int index, int len) {
    final entries = buildOpsFormatContextMenuEntries(setStateCallback, index, len);
    var menu = ContextMenu(
      entries: entries,
      boxDecoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: defaultPalette.black.withOpacity(0.3),
            blurRadius: 2,
          )
        ],
        color: defaultPalette.extras[0],
        borderRadius: BorderRadius.circular(10),
      ),
      position: position,
    );
    menu.show(context);
  }
  
  List<ContextMenuEntry> buildOpsFormatContextMenuEntries(Function setStateCallback, int index, int len) {
    final formats = ["alnum", "alpha", "numeric"];

    return formats.map((s) {
      return MenuItem(
        label: s,
        onSelected: () {
          
            setStateCallback((){_updateToken(index, "{rand~$len~$s}");});
                      
        },
        hoverColor: defaultPalette.primary.withOpacity(0.02),
        unfocusedColor: defaultPalette.primary.withOpacity(0.2),
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.w500,
          color: defaultPalette.primary,
          fontSize: 15,
        ),
      );
    }).toList();
  }

  void _updateToken(int index, String newToken) {
    final matches = RegExp(r"\{(.*?)\}").allMatches(template).toList();
    if (index >= matches.length) return;

    final match = matches[index];
    template = template.replaceRange(match.start, match.end, newToken);
    
  }
  void _addToken(String token) {
  
      if (template.isEmpty) {
        template = token;
      } else {
        template += token;
      }
  }
  Widget _buildRuleEditor(int index, String token, Function setStateCallback, BuildContext context,Map<int, FocusNode> extraFocusNodes) {
    final parts = token.split("~");
    final type = parts[0];

    switch (type) {
      case "rand":
        final len = parts.length > 1 ? int.tryParse(parts[1]) ?? 6 : 6;
        final mode = parts.length > 2 ? parts[2] : "alnum";

        return Container(
          padding: EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(color:defaultPalette.tertiary),
          child: Column(
            children: [
              const SizedBox(height: 2),
              //title icon and close button and randomise button
              Row(
                children: [
                  const SizedBox(width: 4),
                  //randomise
                  ElevatedLayerButton(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                      topLeft: Radius.circular(5),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    animationDuration: const Duration(milliseconds: 100),
                    animationCurve: Curves.ease,
                    topDecoration: BoxDecoration(
                      color: defaultPalette.primary,
                      border: Border.all(color: defaultPalette.extras[0]),
                    ),
                    topLayerChild: Icon(TablerIcons.dice_5, size: 15, color: defaultPalette.extras[0]),
                    baseDecoration: BoxDecoration(
                      color: defaultPalette.extras[0],
                      border: Border.all(color: defaultPalette.extras[0]),
                    ),
                    depth: 2,
                    subfac: 2,
                    buttonHeight: 24,
                    buttonWidth: 24,
                    onClick: () async{
                      

                      setStateCallback((){
                      // inputBlock.removeAt(index);
                      // inputBlockExpansionList.removeAt(index);
                      idKey = Uuid().v4();
                    });
                    },
                  ),
                    
                  Expanded(
                    child: Text("randomStr ",
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexend(
                      letterSpacing: -1,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      height: 1,
                      color: defaultPalette.primary,
                    ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99999),
                    child: Material(
                      color: defaultPalette.transparent,
                      child: InkWell(
                        hoverColor: defaultPalette.primary,
                        splashColor: defaultPalette.primary,
                        highlightColor: defaultPalette.primary,
                        onTap: () {
                          setStateCallback((){_updateToken(index, "");});
                        },
                        child: Icon(
                          TablerIcons.x,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                 const SizedBox(width: 3),
                ],
              ),
              const SizedBox(height: 5),
              //type and length
              Row(
                children: [
                  const SizedBox(width: 4),
                  //type dropdown
                  MouseRegion(
                    cursor:SystemMouseCursors.click,
                    child: GestureDetector(
                      onTapDown:(d){
                        showOpsFormatMenu(context, d.globalPosition, setStateCallback, index, len,);
                      },
                      child: Row(
                        children: [
                          Text(mode,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1,
                            color: defaultPalette.primary,
                          ),
                          ),
                          Icon(TablerIcons.caret_down_filled, size: 12,color:defaultPalette.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  //length slider
                  Expanded(child: Material(
                    color: defaultPalette.transparent,
                    child: Container(
                      decoration:BoxDecoration(
                        color:defaultPalette.extras[0],
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Row(
                        children: sliderPropertyTile(TextEditingController(text: len.toString()), setStateCallback, (value) {
                            final newLen = (value as double).round();
                            setStateCallback((){_updateToken(index, "{rand~$newLen~$mode}");});
                          })
                      ),
                    ),
                  ),),
                  const SizedBox(width: 3),
                ],
              )
            ],
          ),
        );
      case "date":
        final format = parts.length > 1 ? parts[1] : "yyyy-MM-dd";
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(color: defaultPalette.tertiary),
          child: Column(
            children: [
              const SizedBox(height: 2),
              // title row and pick date and close
              Row(
                children: [
                  const SizedBox(width: 4),
                  //add date
                  ElevatedLayerButton(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                      topLeft: Radius.circular(5),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    animationDuration: const Duration(milliseconds: 100),
                    animationCurve: Curves.ease,
                    topDecoration: BoxDecoration(
                      color: defaultPalette.primary,
                      border: Border.all(color: defaultPalette.extras[0]),
                    ),
                    topLayerChild: Icon(TablerIcons.calendar_event, size: 15, color: defaultPalette.extras[0]),
                    baseDecoration: BoxDecoration(
                      color: defaultPalette.extras[0],
                      border: Border.all(color: defaultPalette.extras[0]),
                    ),
                    depth: 2,
                    subfac: 2,
                    buttonHeight: 24,
                    buttonWidth: 24,
                    onClick: () async{
                      dateTime = (await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1800),
                          lastDate: DateTime(2100),
                          barrierColor: defaultPalette.extras[0].withOpacity(0.5),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme: InputDecorationTheme(
                                  labelStyle: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: defaultPalette.extras[0],
                                  ),
                                  hintStyle: GoogleFonts.lexend(
                                    fontSize: 15,
                                    color: defaultPalette.extras[0].withOpacity(0.6),
                                  ),
                                  errorStyle: GoogleFonts.lexend(
                                    fontSize: 15,
                                    color: defaultPalette.extras[0].withOpacity(0.6),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: defaultPalette.tertiary, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                textTheme: Theme.of(context).textTheme.copyWith(
                                  titleLarge: GoogleFonts.lexend(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: defaultPalette.black,
                                  ),
                                  headlineSmall: GoogleFonts.lexend(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: defaultPalette.black,
                                  ),
                                  headlineMedium: GoogleFonts.lexend(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: defaultPalette.black,
                                  ),
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: ButtonStyle(
                                    textStyle: WidgetStateProperty.all(
                                      GoogleFonts.lexend(fontSize: 15, letterSpacing: -1),
                                    ),
                                    foregroundColor: WidgetStateProperty.all(defaultPalette.tertiary),
                                  ),
                                ),
                                datePickerTheme: DatePickerThemeData(
                                  backgroundColor: defaultPalette.primary,
                                  rangePickerBackgroundColor: defaultPalette.tertiary,
                                  elevation: 20,
                                  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return defaultPalette.tertiary;
                                    }
                                    return null;
                                  }),
                                  locale: const Locale('en', 'IN'),
                                  todayBorder: BorderSide.none,
                                  todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return defaultPalette.tertiary;
                                    } else {
                                      return defaultPalette.primary;
                                    }
                                  }),
                                  todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return defaultPalette.primary;
                                    } else {
                                      return defaultPalette.extras[0];
                                    }
                                  }),
                                  yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return defaultPalette.primary;
                                    }
                                    return null;
                                  }),
                                  yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return defaultPalette.tertiary;
                                    } else {
                                      return defaultPalette.transparent;
                                    }
                                  }),
                                  dividerColor: defaultPalette.extras[0].withOpacity(0.4),
                                  confirmButtonStyle: ButtonStyle(
                                    textStyle: WidgetStateProperty.all(
                                      GoogleFonts.lexend(
                                        fontSize: 15,
                                        letterSpacing: -1,
                                        color: defaultPalette.tertiary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  cancelButtonStyle: ButtonStyle(
                                    textStyle: WidgetStateProperty.all(
                                      GoogleFonts.lexend(
                                        fontSize: 15,
                                        letterSpacing: -1,
                                        color: defaultPalette.tertiary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  yearStyle: GoogleFonts.lexend(
                                    fontSize: 15,
                                    color: defaultPalette.tertiary,
                                    letterSpacing: -1,
                                  ),
                                  dayStyle: GoogleFonts.lexend(
                                    fontSize: 15,
                                    color: defaultPalette.tertiary,
                                    letterSpacing: -1,
                                  ),
                                  weekdayStyle: GoogleFonts.lexend(
                                    fontSize: 14,
                                    letterSpacing: -1,
                                    color: defaultPalette.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  headerHeadlineStyle: GoogleFonts.lexend(
                                    fontSize: 30,
                                    letterSpacing: -1,
                                    color: defaultPalette.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  rangePickerHeaderHeadlineStyle: GoogleFonts.lexend(
                                    fontSize: 14,
                                    letterSpacing: -1,
                                    color: defaultPalette.tertiary,
                                  ),
                                  rangePickerHeaderHelpStyle: GoogleFonts.lexend(
                                    fontSize: 14,
                                    letterSpacing: -1,
                                    color: defaultPalette.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                headerHelpStyle: GoogleFonts.lexend(
                                  fontSize: 14,
                                  letterSpacing: -1,
                                  color: defaultPalette.tertiary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      )??(dateTime??DateTime.now()))
                      .copyWith(
                        hour:(dateTime??DateTime.now()).hour,
                        minute: (dateTime??DateTime.now()).minute,
                        second: (dateTime??DateTime.now()).second,
                        millisecond: (dateTime??DateTime.now()).millisecond,
                        microsecond: (dateTime??DateTime.now()).microsecond
                        
                         ); 

                      setStateCallback((){
                      // inputBlock.removeAt(index);
                      // inputBlockExpansionList.removeAt(index);
                      
                    });
                    },
                  ),
                        
                  Expanded(
                    child: Text(
                      "date",
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        height: 1,
                        color: defaultPalette.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99999),
                    child: Material(
                      color: defaultPalette.transparent,
                      child: InkWell(
                        hoverColor: defaultPalette.primary,
                        splashColor: defaultPalette.primary,
                        highlightColor: defaultPalette.primary,
                        onTap: () {
                          setStateCallback(() {
                            _updateToken(index, "");
                          });
                        },
                        child: Icon(
                          TablerIcons.x,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
              ),
              const SizedBox(height: 5),
              // format chooser
              Row(
                children: [
                  const SizedBox(width: 3),
                  Expanded(
                    child:  Material(
                    color: defaultPalette.transparent,
                    child: Container(
                      height: 20,
                      decoration:BoxDecoration(
                        color:defaultPalette.extras[0],
                        borderRadius: BorderRadius.circular(5)
                      ),
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            Text(
                              "format:",
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lexend(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1,
                                color: defaultPalette.extras[3],
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                // onTapOutside: (event) => fontFocusNodes[s].unfocus(),
                                // focusNode: fontFocusNodes[s],
                                controller: TextEditingController(text: format.toString()),
                                cursorColor: defaultPalette.tertiary,
                                selectionControls: ly.NoMenuTextSelectionControls(),
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0),
                                  labelStyle: GoogleFonts.lexend(color: defaultPalette.black),
                                  fillColor: defaultPalette.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                ),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.lexend(
                                    fontSize: 15,
                                    color: defaultPalette.primary,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -1),
                                onChanged: (value) {
                                  // setStateCallback(() {
                                    _updateToken(index, '{date~$value}');
                                    
                              
                                  // });
                                },
                                onFieldSubmitted:(v){
                                  setStateCallback((){});
                                }
                              ),
                            ),
                            const SizedBox(width: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
              ),
              const SizedBox(height: 2),
            ],
          ),
        );
      case "time":
        final format = parts.length > 1 ? parts[1] : "HH:mm:ss";
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(color: defaultPalette.tertiary),
          child: Column(
            children: [
              const SizedBox(height: 2),
              // title row and pick time and close
              Row(
                children: [
                  const SizedBox(width: 4),
                  //add date
                  ElevatedLayerButton(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                      topLeft: Radius.circular(5),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    animationDuration: const Duration(milliseconds: 100),
                    animationCurve: Curves.ease,
                    topDecoration: BoxDecoration(
                      color: defaultPalette.primary,
                      border: Border.all(color: defaultPalette.extras[0]),
                    ),
                    topLayerChild: Icon(TablerIcons.clock_hour_4, size: 15, color: defaultPalette.extras[0]),
                    baseDecoration: BoxDecoration(
                      color: defaultPalette.extras[0],
                      border: Border.all(color: defaultPalette.extras[0]),
                    ),
                    depth: 2,
                    subfac: 2,
                    buttonHeight: 24,
                    buttonWidth: 24,
                    onClick: () async{
                      var picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: (dateTime??DateTime.now()).hour, minute: (dateTime??DateTime.now()).minute),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                labelStyle: GoogleFonts.lexend(
                                  fontSize: 24,
                                  color: defaultPalette.extras[0],
                                ),
                                hintStyle: GoogleFonts.lexend(
                                  fontSize: 15,
                                  color: defaultPalette.extras[0].withOpacity(0.6),
                                ),
                                errorStyle: GoogleFonts.lexend(
                                  fontSize: 15,
                                  color: defaultPalette.extras[0].withOpacity(0.6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: defaultPalette.tertiary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              textTheme: Theme.of(context).textTheme.copyWith(
                                titleLarge: GoogleFonts.lexend(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                                titleMedium: GoogleFonts.lexend(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                                titleSmall: GoogleFonts.lexend(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                                headlineSmall: GoogleFonts.lexend(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                                headlineMedium: GoogleFonts.lexend(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                                bodyLarge: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                                displayLarge: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                                headlineLarge: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.black,
                                ),
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: ButtonStyle(
                                  textStyle: WidgetStateProperty.all(
                                    GoogleFonts.lexend(
                                      fontSize: 15,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  foregroundColor: WidgetStateProperty.all(defaultPalette.tertiary),
                                ),
                              ),
                              timePickerTheme: TimePickerThemeData(
                                backgroundColor: defaultPalette.primary,
                                hourMinuteTextStyle: GoogleFonts.lexend(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  color: defaultPalette.extras[0],
                                  letterSpacing: -1,
                                ),
                                dayPeriodTextStyle: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: defaultPalette.extras[0],
                                  letterSpacing: -1,
                                ),
                                helpTextStyle: GoogleFonts.lexend(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: defaultPalette.extras[0],
                                  letterSpacing: -1,
                                ),
                                entryModeIconColor: defaultPalette.extras[0],
                                dialHandColor: defaultPalette.tertiary,
                                dialBackgroundColor: defaultPalette.primary,
                                hourMinuteColor: defaultPalette.primary,
                                timeSelectorSeparatorTextStyle: WidgetStatePropertyAll(
                                  GoogleFonts.lexend(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w400,
                                    color: defaultPalette.extras[0],
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                            child: Localizations.override(
                              context: context,
                              locale: const Locale('en', 'GB'), // DD/MM/YYYY and 24-hour format
                              child: child!,
                            ),
                          );
                        },
                      );
                      dateTime = (dateTime??DateTime.now()).copyWith(
                        hour: (picked??TimeOfDay(hour: (dateTime??DateTime.now()).hour, minute: (dateTime??DateTime.now()).minute)).hour,
                        minute: (picked??TimeOfDay(hour: (dateTime??DateTime.now()).hour, minute: (dateTime??DateTime.now()).minute)).minute
                      );

                      setStateCallback((){
                      // inputBlock.removeAt(index);
                      // inputBlockExpansionList.removeAt(index);
                      
                    });
                    },
                  ),
                   
                  Expanded(
                    child: Text(
                      "time",
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        height: 1,
                        color: defaultPalette.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99999),
                    child: Material(
                      color: defaultPalette.transparent,
                      child: InkWell(
                        hoverColor: defaultPalette.primary,
                        splashColor: defaultPalette.primary,
                        highlightColor: defaultPalette.primary,
                        onTap: () {
                          setStateCallback(() {
                            _updateToken(index, "");
                          });
                        },
                        child: Icon(
                          TablerIcons.x,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
              ),
              const SizedBox(height: 5),
              // format chooser
              Row(
                children: [
                  const SizedBox(width: 3),
                  Expanded(
                    child:  Material(
                    color: defaultPalette.transparent,
                    child: Container(
                      height: 20,
                      decoration:BoxDecoration(
                        color:defaultPalette.extras[0],
                        borderRadius: BorderRadius.circular(5)
                      ),
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            Text(
                              "format:",
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lexend(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1,
                                color: defaultPalette.extras[3],
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                // onTapOutside: (event) => fontFocusNodes[s].unfocus(),
                                // focusNode: fontFocusNodes[s],
                                controller: TextEditingController(text: format.toString()),
                                cursorColor: defaultPalette.tertiary,
                                selectionControls: ly.NoMenuTextSelectionControls(),
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0),
                                  labelStyle: GoogleFonts.lexend(color: defaultPalette.black),
                                  fillColor: defaultPalette.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                ),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.lexend(
                                    fontSize: 15,
                                    color: defaultPalette.primary,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -1),
                                onChanged: (value) {
                                  // setStateCallback(() {
                                    _updateToken(index, '{time~$value}');
                                    
                              
                                  // });
                                },
                                onFieldSubmitted:(v){
                                  setStateCallback((){});
                                }
                              ),
                            ),
                            const SizedBox(width: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
              ),
              const SizedBox(height: 2),
            ],
          ),
        );
      case "str":
        final format = parts.length > 1 ? parts[1] : "";
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(color: defaultPalette.tertiary),
          child: Column(
            children: [
              const SizedBox(height: 2),
              // title row
              Row(
                children: [
                  const SizedBox(width: 4),
                  Icon(TablerIcons.cursor_text, size: 20, color: defaultPalette.primary),
                  Expanded(
                    child: Text(
                      "text",
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        height: 1,
                        color: defaultPalette.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99999),
                    child: Material(
                      color: defaultPalette.transparent,
                      child: InkWell(
                        hoverColor: defaultPalette.primary,
                        splashColor: defaultPalette.primary,
                        highlightColor: defaultPalette.primary,
                        onTap: () {
                          setStateCallback(() {
                            _updateToken(index, "");
                          });
                        },
                        child: Icon(
                          TablerIcons.x,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
              ),
              const SizedBox(height: 5),
              // format chooser
              Row(
                children: [
                  const SizedBox(width: 3),
                  Expanded(
                    child:  Material(
                    color: defaultPalette.transparent,
                    child: Container(
                      height: 20,
                      decoration:BoxDecoration(
                        color:defaultPalette.extras[0],
                        borderRadius: BorderRadius.circular(5)
                      ),
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            Text(
                              "text:",
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lexend(
                                letterSpacing: -1,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1,
                                color: defaultPalette.extras[3],
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                // onTapOutside: (event) => fontFocusNodes[s].unfocus(),
                                focusNode: extraFocusNodes.putIfAbsent(index,()=>FocusNode()),
                                controller: TextEditingController(text: format.toString()),
                                cursorColor: defaultPalette.tertiary,
                                selectionControls: ly.NoMenuTextSelectionControls(),
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0),
                                  labelStyle: GoogleFonts.lexend(color: defaultPalette.black),
                                  fillColor: defaultPalette.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                ),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.lexend(
                                    fontSize: 15,
                                    color: defaultPalette.primary,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -1),
                                onChanged: (value) {
                                  // setStateCallback(() {
                                    _updateToken(index, '{str~$value}');
                                    
                              
                                  // });
                                },
                                onFieldSubmitted:(v){
                                  setStateCallback((){});
                                }
                              ),
                            ),
                            const SizedBox(width: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
              ),
              const SizedBox(height: 2),
            ],
          ),
        );
      default:
        return Text("Unhandled: {$token}");
    }
  }

  @override
  dynamic result(
    Function getItemAtPath,
    Function buildCombinedQuillConfiguration, {
    List<SheetListBox>? spreadSheet,
    Map<List<InputBlock>, int>? visited,
    bool returnFormatted = false,
  }) {
    
    var newText = UidGenerator.generate(template,idKey: idKey, dateTime:dateTime);
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
  
  @override
  List<Widget> buildPrimaryFunctionBlock(
    BuildContext context,
    InputBlock funcBlock,
    List<InputBlock>? selectedInputBlocks,
    double width,
    Function setStateCallBack,
    List<InputBlock> inputBlock,
    int index,
    SheetText item,
    Offset overlayPosition,
    double overlayHeight,
    Function buildCombinedQuillConfiguration,
    Function getItemAtPath,
    Function customStyleBuilder,
    Function uniStatFunctionInputBlocks,
    Function showPositionedTextFieldOverlay,
    {
      bool isSecondary = false,
      Map<int, FocusNode> extraFocusNodes =const {}
    }

    ){
      
    return [
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: defaultPalette.primary,
              borderRadius: BorderRadius.circular(8).copyWith(
                bottomRight: Radius.circular(funcBlock.isExpanded?0:8),
                bottomLeft: Radius.circular(funcBlock.isExpanded?0:8) 
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 15,),
                //the title of function
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'uidGenerator',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          letterSpacing: -1,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 1,
                          color: defaultPalette.extras[0],
                        ),
                      ),
                    ),
                    const SizedBox(width:8),
                  ],
                ),
                //sum/count and index
          
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: defaultPalette.extras[0],
                        ),
                        child: Row(
                        children: [
                          const SizedBox(width: 3),
                          Icon(TablerIcons.medical_cross_circle, color:defaultPalette.primary, size:14),
                          const SizedBox(width: 3),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.lexend(
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: defaultPalette.extras[0],
                                ),
                                children: [
                                  // TextSpan(text: ' sum: ',style: TextStyle(color:Color(0xffB388EB)),),
                                  TextSpan(
                                    text: getConfigurations(getItemAtPath,buildCombinedQuillConfiguration, setStateCallBack, customStyleBuilder).controller.document.toPlainText(),
                                    style: TextStyle(color:defaultPalette.primary),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          
                          const SizedBox(width: 3),
                        ],
                      ),
                      ),
                    ),
                  
                  ],
                ),

                if(funcBlock.isExpanded)
                  ...[SizedBox(height: 5,),
                  //the label tiles for folded vsalues of x and y
                  Container(
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    decoration:BoxDecoration(
                      color:defaultPalette.transparent,
                      // border:Border.all()
                    ),
                    //reorderable for functioninputblockchildren
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //add date
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.calendar_event, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{date~yyyy-MM-dd}');
                          });
                          },
                        ),
                        //add time
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.clock_hour_4, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{time~HH:mm:ss}');
                          });
                          },
                        ),
                        //addtext
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.cursor_text, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{str~yo}');
                          });
                          },
                        ),
                        //add randomstr
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.dice_5, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{rand~6~alnum}');
                          });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),

                  ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(scrollbars: false),
                    child: DynMouseScroll(
                      durationMS: 500,
                      scrollSpeed: 1,
                      builder: (context, controller, physics) {
                        return ReorderableListView(
                          shrinkWrap: true,
                          buildDefaultDragHandles: false,
                          scrollDirection: Axis.vertical,
                          scrollController:controller,
                          physics:physics,
                          onReorder: (oldIndex, newIndex) {
                            setStateCallBack(() {
                              if (newIndex > oldIndex) newIndex--;

                                final regExp = RegExp(r"\{.*?\}");
                                final matches = regExp.allMatches(template).toList();

                                // Extract tokens
                                final tokens = matches.map((m) => m.group(0)!).toList();

                                // Extract separators
                                final separators = <String>[];
                                int lastEnd = 0;
                                for (final m in matches) {
                                  separators.add(template.substring(lastEnd, m.start));
                                  lastEnd = m.end;
                                }
                                separators.add(template.substring(lastEnd));

                                // Reorder tokens only
                                final item = tokens.removeAt(oldIndex);
                                tokens.insert(newIndex, item);

                                // Rebuild template
                                final buffer = StringBuffer();
                                for (int i = 0; i < tokens.length; i++) {
                                  buffer.write(separators[i]);
                                  buffer.write(tokens[i]);
                                }
                                buffer.write(separators.last);

                                template = buffer.toString(); // update original string
                            });
                          },
                          proxyDecorator: (child, index, animation) {
                            return Container(child: child); },
                          // itemBuilder:(context, index) {
                          //   return RegExp(r"\{(.*?)\}").allMatches(template).toList().asMap().entries.map((entry) {
                          //     return _buildRuleEditor(entry.key, entry.value.group(1)!, setStateCallBack, context);
                          //   },).toList()[index];
                          // },
                          children: [
                            ...RegExp(r"\{(.*?)\}").allMatches(template).toList().asMap().entries.map((entry) {
                              return ReorderableDragStartListener(
                                index: entry.key,
                                key: ValueKey(entry.key),
                                child: _buildRuleEditor(entry.key, entry.value.group(1)!, setStateCallBack, context, extraFocusNodes));
                            },).toList()
                            // for (int i = 0; i < matches.length; i++)
                              
                          ],
                        );
                      }
                    ),
                  ),
                  ],
                  
              ]),
            ),
        ),
      ),
      ElevatedLayerButton(
        
        isTapped: funcBlock.isExpanded,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(5),
          topLeft: Radius.circular(5),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        animationDuration: const Duration(milliseconds: 100),
        animationCurve: Curves.ease,
        topDecoration: BoxDecoration(
          color: defaultPalette.primary,
          border: Border.all(color: defaultPalette.extras[0]),
        ),
        topLayerChild: Row(
          children: [
            const SizedBox(width: 10),
            Icon(TablerIcons.medical_cross_filled, size: 13, color: defaultPalette.extras[0]),
            Expanded(
              child: Text(
                ' edit',
                maxLines: 1,
                style: GoogleFonts.bungee(
                  fontSize: 12,
                  color: defaultPalette.extras[0],
                  // letterSpacing: -1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        baseDecoration: BoxDecoration(
          color: defaultPalette.extras[0],
          border: Border.all(color: defaultPalette.extras[0]),
        ),
        depth: 2,
        subfac: 2,
        buttonHeight: 24,
        buttonWidth: 80,
        onClick: () {
          setStateCallBack(() {
            // inputBlockExpansionList[index] = !// inputBlockExpansionList[index];
            inputBlock[index].isExpanded =!inputBlock[index].isExpanded;
          });
        },
      ),
      Positioned(
        left:81,
        child: ElevatedLayerButton(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              topLeft: Radius.circular(5),
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            animationDuration: const Duration(milliseconds: 100),
            animationCurve: Curves.ease,
            topDecoration: BoxDecoration(
              color: defaultPalette.secondary,
              border: Border.all(color: defaultPalette.extras[0]),
            ),
            topLayerChild: Row(
              children: [
                const SizedBox(width: 2),
                Icon(funcBlock.useConst?TablerIcons.cursor_text:TablerIcons.x, size: 12, color: defaultPalette.extras[0]),
                
              ],
            ),
            baseDecoration: BoxDecoration(
              color: defaultPalette.extras[0],
              border: Border.all(color: defaultPalette.extras[0]),
            ),
            depth: 2,
            subfac: 2,
            buttonHeight: 24,
            buttonWidth: 20,
            onClick: () {
              setStateCallBack(() {
              inputBlock.removeAt(index);
              // inputBlockExpansionList.removeAt(index);
            });
            },
          ),
      ),
    
    ];
                      
  }
  @override
  Widget buildSecondaryFunctionBlock(
    BuildContext context,
    InputBlock funcBlock,
    List<InputBlock>? selectedInputBlocks,
    double width,
    Function setStateCallBack,
    List<InputBlock> inputBlock,
    int index,
    SheetText item,
    Offset overlayPosition,
    double overlayHeight,
    Function buildCombinedQuillConfiguration,
    Function getItemAtPath,
    Function customStyleBuilder,
    Function uniStatFunctionInputBlocks,
    Function showPositionedTextFieldOverlay,
    {
      bool isSecondary = false,
      Map<int, FocusNode> extraFocusNodes =const {}
    }

    ){
    return 
      Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8).copyWith(
            bottomRight: Radius.circular(funcBlock.isExpanded?0:8),
            bottomLeft: Radius.circular(funcBlock.isExpanded?0:8) 
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: defaultPalette.primary,
              borderRadius: BorderRadius.circular(8).copyWith(
                bottomRight: Radius.circular(funcBlock.isExpanded?0:8),
                bottomLeft: Radius.circular(funcBlock.isExpanded?0:8) 
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 15,),
                //the title of function
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'uidGenerator',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          letterSpacing: -1,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 1,
                          color: defaultPalette.extras[0],
                        ),
                      ),
                    ),
                    const SizedBox(width:8),
                  ],
                ),
                //sum/count and index
          
                Row(
                  children: [
                    const SizedBox(width: 2),
                  ElevatedLayerButton(
                  isTapped: funcBlock.isExpanded,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5),
                    topLeft: Radius.circular(5),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  animationDuration: const Duration(milliseconds: 100),
                  animationCurve: Curves.ease,
                  topDecoration: BoxDecoration(
                    color: defaultPalette.primary,
                    border: Border.all(color: defaultPalette.extras[0]),
                  ),
                  topLayerChild: Row(
                    children: [
                      Expanded(child: Icon(TablerIcons.medical_cross_filled, size: 13, color: defaultPalette.extras[0])),
                    ],
                  ),
                  baseDecoration: BoxDecoration(
                    color: defaultPalette.extras[0],
                    border: Border.all(color: defaultPalette.extras[0]),
                  ),
                  depth: 2,
                  subfac: 2,
                  buttonHeight: 24,
                  buttonWidth: 20,
                  onClick: () {
                    setStateCallBack(() {
                      // inputBlockExpansionList[index] = !// inputBlockExpansionList[index];
                      inputBlock[index].isExpanded =!inputBlock[index].isExpanded;
                    });
                  },
                ),
                   const SizedBox(width: 2),
                  ElevatedLayerButton(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5),
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      animationDuration: const Duration(milliseconds: 100),
                      animationCurve: Curves.ease,
                      topDecoration: BoxDecoration(
                        color: defaultPalette.secondary,
                        border: Border.all(color: defaultPalette.extras[0]),
                      ),
                      topLayerChild: Row(
                        children: [
                          const SizedBox(width: 2),
                          Icon(funcBlock.useConst?TablerIcons.cursor_text:TablerIcons.x, size: 12, color: defaultPalette.extras[0]),
                          
                        ],
                      ),
                      baseDecoration: BoxDecoration(
                        color: defaultPalette.extras[0],
                        border: Border.all(color: defaultPalette.extras[0]),
                      ),
                      depth: 2,
                      subfac: 2,
                      buttonHeight: 24,
                      buttonWidth: 20,
                      onClick: () {
                        setStateCallBack(() {
                        inputBlock.removeAt(index);
                        // inputBlockExpansionList.removeAt(index);
                      });
                      },
                    ),
          
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: defaultPalette.extras[0],
                        ),
                        child: Row(
                        children: [
                          const SizedBox(width: 3),
                          Icon(TablerIcons.medical_cross_circle, color:defaultPalette.primary, size:14),
                          const SizedBox(width: 3),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.lexend(
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: defaultPalette.extras[0],
                                ),
                                children: [
                                  // TextSpan(text: ' sum: ',style: TextStyle(color:Color(0xffB388EB)),),
                                  TextSpan(
                                    text: getConfigurations(getItemAtPath,buildCombinedQuillConfiguration, setStateCallBack, customStyleBuilder).controller.document.toPlainText(),
                                    style: TextStyle(color:defaultPalette.primary),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          
                          const SizedBox(width: 3),
                        ],
                      ),
                      ),
                    ),
                  
                  ],
                ),
        
                if(funcBlock.isExpanded)
                  ...[SizedBox(height: 5,),
                  //the label tiles for folded vsalues of x and y
                  Container(
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    decoration:BoxDecoration(
                      color:defaultPalette.transparent,
                      // border:Border.all()
                    ),
                    //reorderable for functioninputblockchildren
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //add date
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.calendar_event, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{date~yyyy-MM-dd}');
                          });
                          },
                        ),
                        //add time
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.clock_hour_4, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{time~HH:mm:ss}');
                          });
                          },
                        ),
                        //addtext
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.cursor_text, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{str~yo}');
                          });
                          },
                        ),
                        //add randomstr
                        ElevatedLayerButton(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          animationDuration: const Duration(milliseconds: 100),
                          animationCurve: Curves.ease,
                          topDecoration: BoxDecoration(
                            color: defaultPalette.primary,
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          topLayerChild: Icon(TablerIcons.dice_5, size: 15, color: defaultPalette.extras[0]),
                          baseDecoration: BoxDecoration(
                            color: defaultPalette.extras[0],
                            border: Border.all(color: defaultPalette.extras[0]),
                          ),
                          depth: 2,
                          subfac: 2,
                          buttonHeight: 24,
                          buttonWidth: width/4-4,
                          onClick: () {
                            setStateCallBack(() {
                            // inputBlock.removeAt(index);
                            // inputBlockExpansionList.removeAt(index);
                            _addToken('{rand~6~alnum}');
                          });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
        
                  ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(scrollbars: false),
                    child: DynMouseScroll(
                      durationMS: 500,
                      scrollSpeed: 1,
                      builder: (context, controller, physics) {
                        return ReorderableListView(
                          shrinkWrap: true,
                          buildDefaultDragHandles: false,
                          scrollDirection: Axis.vertical,
                          scrollController:controller,
                          physics:physics,
                          onReorder: (oldIndex, newIndex) {
                            setStateCallBack(() {
                              if (newIndex > oldIndex) newIndex--;
        
                                final regExp = RegExp(r"\{.*?\}");
                                final matches = regExp.allMatches(template).toList();
        
                                // Extract tokens
                                final tokens = matches.map((m) => m.group(0)!).toList();
        
                                // Extract separators
                                final separators = <String>[];
                                int lastEnd = 0;
                                for (final m in matches) {
                                  separators.add(template.substring(lastEnd, m.start));
                                  lastEnd = m.end;
                                }
                                separators.add(template.substring(lastEnd));
        
                                // Reorder tokens only
                                final item = tokens.removeAt(oldIndex);
                                tokens.insert(newIndex, item);
        
                                // Rebuild template
                                final buffer = StringBuffer();
                                for (int i = 0; i < tokens.length; i++) {
                                  buffer.write(separators[i]);
                                  buffer.write(tokens[i]);
                                }
                                buffer.write(separators.last);
        
                                template = buffer.toString(); // update original string
                            });
                          },
                          proxyDecorator: (child, index, animation) {
                            return Container(child: child); },
                          // itemBuilder:(context, index) {
                          //   return RegExp(r"\{(.*?)\}").allMatches(template).toList().asMap().entries.map((entry) {
                          //     return _buildRuleEditor(entry.key, entry.value.group(1)!, setStateCallBack, context);
                          //   },).toList()[index];
                          // },
                          children: [
                            ...RegExp(r"\{(.*?)\}").allMatches(template).toList().asMap().entries.map((entry) {
                              return ReorderableDragStartListener(
                                index: entry.key,
                                key: ValueKey(entry.key),
                                child: _buildRuleEditor(entry.key, entry.value.group(1)!, setStateCallBack, context, extraFocusNodes));
                            },).toList()
                            // for (int i = 0; i < matches.length; i++)
                              
                          ],
                        );
                      }
                    ),
                  ),
                  ],
                  
              ]),
            ),
        ),
            
         );
                      
  }
  

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
List<Widget> sliderPropertyTile(TextEditingController s, Function setStateCallback, Function onChange) {
    
  return [
    MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onHorizontalDragCancel: () {
        },
        onHorizontalDragUpdate: (details) {
          var multiplier = HardwareKeyboard.instance.isControlPressed
              ? 10
              : HardwareKeyboard.instance.isShiftPressed
                  ? 0.1
                  : 1;
          // setStateCallback(() {
            double currentValue =
                double.tryParse(s.text) ??
                    0.0;
            double newValue = (currentValue + details.delta.dx * multiplier)
                .clamp(0.1, double.infinity);

            double parsedValue = double.parse(newValue.toStringAsFixed(4));
            onChange(parsedValue);
            
          // });
        },
        child: Row(
          children: [
            const SizedBox(width: 3),
            Text(' length:',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                letterSpacing: -1,
                color: defaultPalette.extras[3]),
            ),
          ],
        ),
      ),
    ),
    Expanded(
      flex: 10,
      child: SizedBox(
        height: 15,
        child: TextFormField(
          // onTapOutside: (event) => fontFocusNodes[s].unfocus(),
          // focusNode: fontFocusNodes[s],
          controller: s,
          inputFormatters: [
            NumericInputFormatter(allowNegative: false),
          ],
          cursorColor: defaultPalette.tertiary,
          selectionControls: ly.NoMenuTextSelectionControls(),
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0),
            labelStyle: GoogleFonts.lexend(color: defaultPalette.black),
            fillColor: defaultPalette.transparent,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
          style: GoogleFonts.mitr(
              fontSize: 15,
              color: defaultPalette.primary,
              fontWeight: FontWeight.w400,
              letterSpacing: -1),
          onFieldSubmitted: (value) {
            setStateCallback(() {
              print(value);
            var parsedValue = (double.tryParse(value)??0.0);
            onChange(parsedValue);
              

            });
          },
        ),
      ),
    ),
    SizedBox(
      width: 2,
    ),
  ];
  }
  

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
