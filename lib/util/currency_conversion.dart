import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; 
import 'package:intl/src/intl/number_format.dart';
import 'package:path_provider/path_provider.dart';


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

Future<File> _getRatesFile() async {
  final dir = await getApplicationSupportDirectory(); 
  // This folder is NOT user-accessible on iOS/Android, 
  // and less obvious on desktop.
  return File('${dir.path}/fx_rates.json');
}

Future<Map<String, double>> fetchFxRates({bool useCache = true}) async {
  final file = await _getRatesFile();

  

  // 2️⃣ Fetch fresh from API
  final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
  try {
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Fetched FX rates: ${data['rates']} rates');
  
    final rawRates = Map<String, dynamic>.from(data['rates']);
    final rates = rawRates.map((key, value) {
      return MapEntry(key, (value as num).toDouble());
    });
  
    // 3️⃣ Save to cache
    await file.writeAsString(jsonEncode(rates));
  
    return rates;
  } else {
    // 1️⃣ Try reading from cache first
  if (useCache && await file.exists()) {
    try {
      final cached = jsonDecode(await file.readAsString());
      final cachedRates = Map<String, double>.from(
        (cached as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      );
      return cachedRates;
    } catch (e) {
      
     // fallback to API fetch below
    }
  }
  }
} on Exception catch (e) {
  if (useCache && await file.exists()) {
    try {
      final cached = jsonDecode(await file.readAsString());
      final cachedRates = Map<String, double>.from(
        (cached as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      );
      return cachedRates;
    } catch (e) {
      
     // fallback to API fetch below
    }
  }
} finally {
    return {
    "USD": 1, "AED": 3.67, "AFN": 68.09, "ALL": 82.43, "AMD": 383.31,
    "ANG": 1.79, "AOA": 924.9, "ARS": 1462, "AUD": 1.5, "AWG": 1.79, "AZN": 1.7,
    "BAM": 1.66, "BBD": 2, "BDT": 121.66, "BGN": 1.66, "BHD": 0.376, "BIF": 2985.7,
    "BMD": 1, "BND": 1.28, "BOB": 6.91, "BRL": 5.33, "BSD": 1, "BTN": 88.2,
    "BWP": 13.71, "BYN": 3.26, "BZD": 2, "CAD": 1.38, "CDF": 2866.91, "CHF": 0.795,
    "CLP": 953.17, "CNY": 7.12, "COP": 3893.43, "CRC": 503.13, "CUP": 24,
    "CVE": 93.76, "CZK": 20.68, "DJF": 177.72, "DKK": 6.34, "DOP": 63.26,
    "DZD": 129.59, "EGP": 48.18, "ERN": 15, "ETB": 142.47, "EUR": 0.85, "FJD": 2.23,
    "FKP": 0.735, "FOK": 6.34, "GBP": 0.735, "GEL": 2.7, "GGP": 0.735, "GHS": 12.6,
    "GIP": 0.735, "GMD": 73.31, "GNF": 8688.15, "GTQ": 7.66, "GYD": 209.17,
    "HKD": 7.78, "HNL": 26.17, "HRK": 6.41, "HTG": 130.89, "HUF": 331.22,
    "IDR": 16405.56, "ILS": 3.35, "IMP": 0.735, "INR": 88.2, "IQD": 1308.1,
    "IRR": 42416.02, "ISK": 121.88, "JEP": 0.735, "JMD": 160.41, "JOD": 0.709,
    "JPY": 147.39, "KES": 129.09, "KGS": 87.45, "KHR": 4010.04, "KID": 1.5,
    "KMF": 418.31, "KRW": 1385.98, "KWD": 0.305, "KYD": 0.833, "KZT": 540.65,
    "LAK": 21688.81, "LBP": 89500, "LKR": 301.6, "LRD": 177.7, "LSL": 17.36,
    "LYD": 5.41, "MAD": 9, "MDL": 16.58, "MGA": 4460.48, "MKD": 52.48, "MMK": 2097.82,
    "MNT": 3559, "MOP": 8.01, "MRU": 40, "MUR": 45.51, "MVR": 15.41, "MWK": 1742.38,
    "MXN": 18.37, "MYR": 4.2, "MZN": 63.68, "NAD": 17.36, "NGN": 1498.56,
    "NIO": 36.76, "NOK": 9.83, "NPR": 141.12, "NZD": 1.68, "OMR": 0.384, "PAB": 1,
    "PEN": 3.49, "PGK": 4.2, "PHP": 57.15, "PKR": 283.29, "PLN": 3.61, "PYG": 7117.45,
    "QAR": 3.64, "RON": 4.3, "RSD": 99.62, "RUB": 82.84, "RWF": 1453.61, "SAR": 3.75,
    "SBD": 8.27, "SCR": 15.05, "SDG": 453.9, "SEK": 9.28, "SGD": 1.28, "SHP": 0.735,
    "SLE": 23.33, "SLL": 23326.15, "SOS": 571.78, "SRD": 39.25, "SSP": 4720.47,
    "STN": 20.83, "SYP": 13074.21, "SZL": 17.36, "THB": 31.8, "TJS": 9.45, "TMT": 3.5,
    "TND": 2.9, "TOP": 2.38, "TRY": 41.32, "TTD": 6.76, "TVD": 1.5, "TWD": 30.18,
    "TZS": 2455.9, "UAH": 41.23, "UGX": 3503.36, "UYU": 40.03, "UZS": 12308.05,
    "VES": 160.45, "VND": 26236.59, "VUV": 117.57, "WST": 2.73, "XAF": 557.75,
    "XCD": 2.7, "XCG": 1.79, "XDR": 0.728, "XOF": 557.75, "XPF": 101.47, "YER": 239.26,
    "ZAR": 17.36, "ZMW": 23.8, "ZWL": 26.73
  };
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
