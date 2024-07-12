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
      // Handle leading zero
      if (newValue.text.length > 1 &&
          newValue.text.startsWith('0') &&
          newValue.text[1] != '.') {
        final newText = newValue.text.substring(1);
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
      // Allow empty value
      if (newValue.text.isEmpty) {
        return TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      // Handle case where last character is a dot
      if (newValue.text.endsWith('.')) {
        return newValue;
      }

      // Parse the new value as double
      double parsedValue;
      try {
        parsedValue = double.parse(newValue.text);
      } catch (e) {
        // If parsing fails, return oldValue
        return oldValue;
      }

      // Limit the value to maxValue if provided
      if (maxValue != null && parsedValue > maxValue!) {
        parsedValue = maxValue!;
      }

      // Round parsedValue to 3 decimals and remove trailing zeros
      String formattedText = _formatNumber(parsedValue);

      // Calculate the new selection offset
      int offset = newValue.selection.end;
      if (newValue.text.contains('.') && !formattedText.contains('.')) {
        offset -= 1; // Adjust for removed dot
      }

      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: offset),
      );
    }

    // If the new value contains illegal characters, return the old value
    return oldValue;
  }

  String _formatNumber(double value) {
    String formattedText = value.toStringAsFixed(3); // Format to 3 decimals
    // Remove trailing zeros and decimal point if all decimals are zeros
    formattedText = formattedText.contains('.')
        ? formattedText
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '')
        : formattedText;
    return formattedText;
  }
}
