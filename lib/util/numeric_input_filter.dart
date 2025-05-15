import 'package:flutter/services.dart';

class NumericInputFormatter extends TextInputFormatter {
  final double? maxValue; // Maximum allowed numeric value (optional)
  final bool allowNegative; // Toggle for allowing negative numbers

  NumericInputFormatter({this.maxValue, this.allowNegative = false});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // 1) Empty → “0”
    if (text.isEmpty) {
      return TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // 2) Check for negative sign if allowed
    final regex = allowNegative 
        ? RegExp(r'^-?\d*\.?\d*$') 
        : RegExp(r'^\d*\.?\d*$');

    // 3) Only allow digits and at most one dot (and negative if enabled)
    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    // 4) Remove leading zeros unless it’s "0." or "-0."
    if ((text.length > 1 && text.startsWith('0') && !text.startsWith('0.')) ||
        (text.length > 2 && text.startsWith('-0') && !text.startsWith('-0.'))) {
      final stripped = text.startsWith('-') ? '-${text.substring(2)}' : text.substring(1);
      return TextEditingValue(
        text: stripped,
        selection: TextSelection.collapsed(offset: stripped.length),
      );
    }

    // 5) If it ends in a dot, let them type the fraction
    if (text.endsWith('.')) {
      return newValue;
    }

    // 6) No decimal point, echo integer typed (no trailing .0)
    if (!text.contains('.')) {
      final intVal = int.tryParse(text) ?? 0;
      final clamped = (maxValue != null && intVal.abs() > maxValue!)
          ? (intVal.isNegative ? -maxValue!.toInt() : maxValue!.toInt()).toString()
          : text;
      return TextEditingValue(
        text: clamped,
        selection: TextSelection.collapsed(offset: clamped.length),
      );
    }

    // 7) For decimal numbers, parse, clamp, and trim unnecessary zeros
    double value;
    try {
      value = double.parse(text);
    } catch (_) {
      return oldValue;
    }

    if (maxValue != null && value.abs() > maxValue!) {
      value = value.isNegative ? -maxValue! : maxValue!;
    }

    // Format the value without trailing ".0"
    String formatted = value.toString();
    if (formatted.endsWith('.0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
