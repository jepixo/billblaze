// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:billblaze/home.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:hive/hive.dart';

import 'package:billblaze/models/input_block.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';

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
