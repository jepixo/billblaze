import 'dart:convert';
import 'package:http/http.dart' as http;

Future<double> convertCurrency({
  required double amount,
  required String from,
  required String to,
}) async {
  final url = Uri.parse(
      'https://api.frankfurter.app/latest?amount=$amount&from=$from&to=$to');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['rates'][to]; // e.g. 1 USD -> INR value
  } else {
    throw Exception('Failed to fetch exchange rate');
  }
}
