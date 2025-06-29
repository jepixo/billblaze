import 'package:billblaze/models/bill/required_text.dart';
import 'package:billblaze/models/index_path.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_item.dart';
import 'package:billblaze/models/spread_sheet_lib/sheet_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';


class RequiredTextInputFormatter extends TextInputFormatter {
  final List<RequiredText> labelList;
  final SheetText sheetText;
  final SheetItem Function(IndexPath indexPath) getItemAtPath;
  final bool Function(int index, int length, Object? data) Function(int index,QuillController controller) getReplaceTextFunctionForType;
  final void Function(void Function() fn) setState;
  RequiredTextInputFormatter({
    required this.labelList,
    required this.sheetText,
    required this.getItemAtPath,
    required this.getReplaceTextFunctionForType,
    required this.setState
  });

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final inputValue = newValue.text;

    for (var requiredText in labelList) {
      if (inputValue == requiredText.name) {
        print('yes input match');
        final path = requiredText.indexPath;

        if (path.index == -951) {
          print('yes index -951');
          requiredText.indexPath = sheetText.indexPath;
          sheetText.type = SheetTextType.values[requiredText.sheetTextType];
          sheetText.textEditorConfigurations.controller.onReplaceText = getReplaceTextFunctionForType(requiredText.sheetTextType,sheetText.textEditorConfigurations.controller );
          print('yes index ' +requiredText.indexPath.toString());
        } else {
          print(path);
          final item = getItemAtPath(path);
          if (item.id == 'yo' || item.id.isEmpty) {
            requiredText.indexPath = sheetText.indexPath;
            sheetText.type = SheetTextType.values[requiredText.sheetTextType];
          } else {
            return newValue;
            // requiredText.name = '${requiredText.name}-1';
          }
        }
      }
    }

    // Final validation pass
    for (var requiredText in labelList) {
      final item = getItemAtPath(requiredText.indexPath);
      if (item.id == 'yo' || item.id.isEmpty||(item as SheetText).name != requiredText.name) {
        if (requiredText.indexPath.index != -951) {
          
            requiredText.indexPath = IndexPath(index: -951);
          
        }
        
      }
    }
    return newValue;
  }
}
