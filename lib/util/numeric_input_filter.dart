
import 'package:flutter/services.dart';

class NumericInputFormatter extends TextInputFormatter {
  final double? maxValue; // Maximum allowed numeric value (optional)

  NumericInputFormatter({this.maxValue});

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

  // 2) Only digits & at most one dot
  final regex = RegExp(r'^\d*\.?\d*$');
  if (!regex.hasMatch(text)) {
    return oldValue;
  }

  // 3) Strip leading zero unless it’s "0." prefix
  if (text.length > 1 && text.startsWith('0') && !text.startsWith('0.')) {
    final stripped = text.substring(1);
    return TextEditingValue(
      text: stripped,
      selection: TextSelection.collapsed(offset: stripped.length),
    );
  }

  // 4) If it ends in a dot, let them type the fraction
  if (text.endsWith('.')) {
    return newValue;
  }

  // 5) If no decimal point at all, just echo the integer they typed (no .0!)
  if (!text.contains('.')) {
    // optionally clamp to maxValue
    final intVal = int.tryParse(text) ?? 0;
    final clamped = (maxValue != null && intVal > maxValue!)
        ? maxValue!.toInt().toString()
        : text;
    return TextEditingValue(
      text: clamped,
      selection: TextSelection.collapsed(offset: clamped.length),
    );
  }

  // 6) Otherwise we have a decimal number: parse, clamp, and trim zeros
  double value;
  try {
    value = double.parse(text);
  } catch (_) {
    return oldValue;
  }

  if (maxValue != null && value > maxValue!) {
    value = maxValue!;
  }

  // Trim unnecessary zeros/trailing dot
  String formatted = value.toStringAsFixed(3)
    .replaceFirst(RegExp(r'\.?0*$'), '');

  return TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: formatted.length),
  );
}
  
}
