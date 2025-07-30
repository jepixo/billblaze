// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:billblaze/home.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_list.dart';
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

  SumFunction(this.inputBlocks) : super(1, 'sum');

  @override
  dynamic result(
      Function getItemAtPath, 
      Function buildCombinedQuillConfiguration,
      {
      List<SheetListBox>? spreadSheet,
    }) {
    double sum = 0;

    for (final block in inputBlocks) {
      dynamic item;

      if (spreadSheet == null) {
        item = getItemAtPath(block.indexPath);
      } else {
        item = getItemAtPath(block.indexPath, spreadSheet);
      }

      if (item == null) continue;

      // 1) If it's a nested Sheet‐formula
      if (block.function != null && !block.useConst) {
        // a) InputBlockFunction: grab its editor, read text, parse
        if (block.function is InputBlockFunction) {
          final ibf = block.function as InputBlockFunction;
          final config = ibf.getConfigurations( buildCombinedQuillConfiguration, spreadSheet: spreadSheet,
          );
          final text = config.controller.document
              .toPlainText()
              .trim();
          final parsed = double.tryParse(text);
          if (parsed != null) sum += parsed;
        }
        // b) Any other formula: call its .result recursively
        else {
          final value = block.function!.result(
            getItemAtPath,
            buildCombinedQuillConfiguration,
            spreadSheet: spreadSheet,
          );
          if (value is num) sum += value.toDouble();
        }
        continue;
      }

      // 2) Live SheetText in editor
      if (item is SheetText) {
        final text = item.textEditorConfigurations.controller.document
            .toPlainText()
            .trim();
        final parsed = double.tryParse(text);
        if (parsed != null) sum += parsed;
      }
      // 3) SheetTextBox (loaded JSON)
      else if (item is SheetTextBox) {
        try {
          final json = item.textEditorController;
          if (json is List) {
            final delta = Delta.fromJson(json);
            final doc = Document.fromDelta(delta);
            final text = doc.toPlainText().trim();
            final parsed = double.tryParse(text);
            if (parsed != null) sum += parsed;
          }
        } catch (e, st) {
          print('⚠️ Failed to parse SheetTextBox content: $e\n$st');
        }
      }

      // 4) (optional) other types…
    }

    return sum;
  }


  @override
  Map<String, dynamic> toMap() => {
        'type': 'sum',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
      };

  factory SumFunction.fromMap(Map<String, dynamic> map) => SumFunction(
        (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
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

  ColumnFunction({required this.inputBlocks, required this.func, required this.axisLabel}) : super(0, 'column');

  @override
  dynamic result(Function getItemAtPath,
   Function buildCombinedQuillConfiguration,
   {
    List<SheetListBox>? spreadSheet,
  }) {
    switch (func) {
      case 'sum':
      // print(inputBlocks);
      var sumfunc = SumFunction(inputBlocks);
        // print(sumfunc.result(getItemAtPath, spreadSheet: spreadSheet).toString());
        return SumFunction(inputBlocks).result(getItemAtPath, buildCombinedQuillConfiguration, spreadSheet: spreadSheet);
      
      case 'count':
        return CountFunction(inputBlocks: inputBlocks).result(getItemAtPath,buildCombinedQuillConfiguration, spreadSheet: spreadSheet);
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
      };

  factory ColumnFunction.fromMap(Map<String, dynamic> map) => ColumnFunction(
      inputBlocks: 
        (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
        func:
            map['func'],
        axisLabel: map['axisLabel']

      );

}

@HiveType(typeId:20)
class CountFunction extends SheetFunction {
  @HiveField(2)
  List<InputBlock> inputBlocks;

  @override
  result(Function getItemAtPath, Function buildCombinedQuillConfiguration,{List<SheetListBox>? spreadSheet,}) {
    return inputBlocks.length;
  }

  CountFunction(
    {required this.inputBlocks,}
  ):super(1,'count');

   @override
  Map<String, dynamic> toMap() => {
        'type': 'count',
        'returnType': returnType,
        'name': name,
        'inputBlocks': inputBlocks.map((e) => e.toMap()).toList(),
      };

  factory CountFunction.fromMap(Map<String, dynamic> map) => CountFunction(
        inputBlocks: (map['inputBlocks'] as List)
            .map((e) => InputBlock.fromMap(e))
            .toList(),
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
  result(Function getItemAtPath, Function buildCombinedQuillConfiguration, {List<SheetListBox>? spreadSheet}) {
    if (spreadSheet!=null) {
      return buildCombinedTextFromBlocks(inputBlocks, spreadSheet);
    }
  }

  QuillEditorConfigurations getConfigurations(buildCombinedQuillConfiguration, {List<SheetListBox>? spreadSheet}) {
    if (spreadSheet !=null) {
      return buildCombinedQuillConfiguration(inputBlocks, spreadSheet,);
    }
    return buildCombinedQuillConfiguration(inputBlocks);
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
