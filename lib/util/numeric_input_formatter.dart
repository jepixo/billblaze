import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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


class NumberFormatUtils {
  static Map<String, dynamic> toMap(NumberFormat format) {
    final Map<String, dynamic> formatMap = {
      'type': _detectFormatType(format),
      'locale': format.locale,
    };

    if (format is NumberFormat) {
      try {
        // This will throw if pattern isn't accessible; catch it silently
        formatMap['pattern'] = format.symbols.DECIMAL_SEP; // placeholder
      } catch (_) {}
    }

    if (format is NumberFormat) {
      // For currency
      if (format.currencyName != null || format.currencySymbol != null) {
        formatMap['currencySymbol'] = format.currencySymbol;
        formatMap['decimalDigits'] = format.decimalDigits;
      }
    }

    return formatMap;
  }

  static NumberFormat fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String? ?? 'decimal';
    final locale = map['locale'] as String?;
    final currencySymbol = map['currencySymbol'] as String?;
    final decimalDigits = map['decimalDigits'] as int?;

    switch (type) {
      case 'currency':
        return NumberFormat.currency(
          locale: locale,
          symbol: currencySymbol,
          decimalDigits: decimalDigits,
        );
      case 'percent':
        return NumberFormat.percentPattern(locale);
      case 'compact':
        return NumberFormat.compact(locale: locale);
      case 'decimal':
      default:
        return NumberFormat.decimalPattern(locale);
    }
  }

  static String _detectFormatType(NumberFormat format) {
    final name = format.toString().toLowerCase();

    if (name.contains('currency')) return 'currency';
    if (name.contains('percent')) return 'percent';
    if (name.contains('compact')) return 'compact';
    return 'decimal';
  }
}
