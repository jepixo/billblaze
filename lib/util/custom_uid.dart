import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // for hashing
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class UidGenerator {
  static int _seq = 0;

  static String generate(String template, {String? idKey}) {
    _seq++;

    return template.replaceAllMapped(RegExp(r"\{(.*?)\}"), (match) {
      final token = match.group(1)!;
      final parts = token.split("~");

      switch (parts[0]) {
        case "date":
          final format = parts.length > 1 ? parts[1] : "yyyy-MM-dd";
          return DateFormat(format).format(DateTime.now());

        case "time":
          final format = parts.length > 1 ? parts[1] : "HH:mm:ss";
          return DateFormat(format).format(DateTime.now());

        case "millis":
          return DateTime.now().millisecondsSinceEpoch.toString();

        case "seq":
          return _seq.toString();

        case "rand":
          // {rand:8:alpha} or {rand:6:numeric} or {rand:12:alnum}
          final len = parts.length > 1 ? int.tryParse(parts[1]) ?? 6 : 6;
          final mode = parts.length > 2 ? parts[2] : "alnum";

          if (idKey != null) {
            return _deterministicString(idKey, len, mode);
          } else {
            return _randomString(len, mode);
          }

        case "prefix":
          return parts.length > 1 ? parts[1] : "";
        case "str":
          final str = parts.length > 1 ? parts[1] : "";
          return str;

        default:
          return match.group(0)!;
      }
    });
  }

  static String _randomString(int length, String mode) {
    Random _rng = Random();
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const digits = "0123456789";
    late String chars;

    switch (mode) {
      case "numeric":
        chars = digits;
        break;
      case "alpha":
        chars = letters;
        break;
      case "alnum":
      default:
        chars = letters + digits;
        break;
    }

    return List.generate(length, (_) => chars[_rng.nextInt(chars.length)]).join();
  }

  static String _deterministicString(String idKey, int length, String mode) {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const digits = "0123456789";
    late String chars;

    switch (mode) {
      case "numeric":
        chars = digits;
        break;
      case "alpha":
        chars = letters;
        break;
      case "alnum":
      default:
        chars = letters + digits;
        break;
    }

    // hash the idKey
    final hash = sha256.convert(utf8.encode(idKey)).bytes;

    // use hash bytes to select characters
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(chars[hash[i % hash.length] % chars.length]);
    }
    return buffer.toString();
  }
}
