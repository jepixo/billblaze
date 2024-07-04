import 'package:flutter/services.dart';

class NumericInputFormatter extends TextInputFormatter {
  final double? maxValue; // Maximum allowed numeric value (optional)

  NumericInputFormatter({this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final RegExp regex = RegExp(r'^\d*\.?\d*$');

    // If the new value contains only legal characters
    if (regex.hasMatch(newValue.text)) {
      // Remove starting zero if followed by another digit
      if (newValue.text.length > 1 &&
          newValue.text.startsWith('0') &&
          newValue.text[1] != '.') {
        final newText = newValue.text.substring(1);
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
      // If the new value is empty, return '0'
      if (newValue.text.isEmpty) {
        return TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
        );
      }

      // Parse the new value as double
      double parsedValue;
      try {
        parsedValue = double.parse(newValue.text);
      } catch (e) {
        // If parsing fails, return oldValue
        return oldValue;
      }

      // Round parsedValue to 5 decimals and remove trailing zeros
      String formattedText = _formatNumber(parsedValue);

      // Limit the value to maxValue if provided
      if (maxValue != null && parsedValue > maxValue!) {
        parsedValue = maxValue!;
        formattedText = _formatNumber(parsedValue);
      }

      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    // If the new value contains illegal characters, return the old value
    return oldValue;
  }

  String _formatNumber(double value) {
    String formattedText = value.toStringAsFixed(3); // Format to 5 decimals
    // Remove trailing zeros and decimal point if all decimals are zeros
    formattedText = formattedText.contains('.')
        ? formattedText
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '')
        : formattedText;
    return formattedText;
  }
}
