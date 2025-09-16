import 'dart:convert';
import 'package:http/http.dart' as http; 
import 'package:intl/src/intl/number_format.dart';


double convertCurrency({
  required double amount,
  required String from,
  required String to,
  required Map<String, double> rates,
}) {
  if (from == to) return amount;
  final fromRate = rates[from];
  final toRate = rates[to];

  if (fromRate == null || toRate == null) {
    throw Exception('Missing FX rate for $from or $to');
  }

  final amountInBase = amount / fromRate;
  return amountInBase * toRate;
}

Future<Map<String, double>> fetchFxRates() async {
  final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Fetched FX rates: ${data['rates']} rates');

    final rawRates = Map<String, dynamic>.from(data['rates']);
    final rates = rawRates.map((key, value) {
      return MapEntry(key, (value as num).toDouble()); // ✅ safe cast to double
    });

    return rates;
  } else {
    throw Exception('Failed to load FX rates');
  }
}

class DynamicCurrencyFormatter {
  String locale;
  String currencyCode;

  DynamicCurrencyFormatter({
    required this.locale,
    required this.currencyCode,
  });

  String format(double value) {
    final hasDecimals = value % 1 != 0;
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: hasDecimals ? 2 : 0,
    );
    return formatter.format(value);
  }

  // Optionally allow changing currency globally
  void updateCurrency(String newCode) {
    currencyCode = newCode;
  }
}
