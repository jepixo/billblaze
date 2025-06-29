import 'package:flutter/services.dart';

class HexColorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newText = newValue.text.toUpperCase();

    if (newText.isEmpty || newText == '#') {
      return newValue.copyWith(
        text: '#',
        selection: TextSelection.fromPosition(
          TextPosition(offset: 1),
        ),
      );
    }

    // Updated regular expression to allow 8 hex digits for transparency
    final RegExp hexColorExp = RegExp(r'^#([0-9A-F]{0,8})$');

    if (hexColorExp.hasMatch(newText)) {
      return newValue;
    }

    return oldValue;
  }
}
