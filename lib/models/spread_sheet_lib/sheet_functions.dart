// ignore_for_file: public_member_api_docs, sort_constructors_first

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

  dynamic result(Function getItemAtPath) {
    throw UnimplementedError('Subclasses must override result()');
  }
}

@HiveType(typeId:17)
class SumFunction extends SheetFunction {
  @HiveField(2)
  List<InputBlock> inputBlocks;

  SumFunction(this.inputBlocks) : super(1, 'sum');

  @override
  dynamic result(Function getItemAtPath) {
    double sum = 0;

    for (final block in inputBlocks) {
      final item = getItemAtPath(block.indexPath);

      if (item == null) continue;

      // If the block is directly tied to a function, call its result
      if (block.function != null) {
        final value = block.function!.result(getItemAtPath);
        if (value is num) {
          sum += value.toDouble();
        }
        // skip if it's a string/bool/anything else
        continue;
      }

      // Handle raw items: check type and apply if it's numeric
      if (item is SheetText) {
        final text = item.textEditorConfigurations.controller.document.toPlainText().trim();
        final parsed = double.tryParse(text);
        if (parsed != null) {
          sum += parsed;
        }
      }

      // Extend here if you want to handle other SheetItem types like SheetListBox, SheetTableCell, etc.
    }

    return sum;
  }
}

class IfFunction extends SheetFunction {
  IfFunction():super(1,'if');
}

class CountFunction extends SheetFunction {
  CountFunction():super(1,'count');
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
