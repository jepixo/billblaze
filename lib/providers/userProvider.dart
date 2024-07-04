// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:billblaze/models/LoggedUserModel.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billblaze/repo/userRepository.dart';

String createId(String input) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ@#!%&*?=+-_';

  // Create a SHA-256 hash of the input string
  List<int> bytes = utf8.encode(input); // Convert input string to UTF-8 bytes

  crypto.Digest hash = crypto.sha256.convert(bytes); // Calculate SHA-256 hash

  // Convert the hash bytes to a string representation
  String hashString = hash.toString();

  // Take the first 7 characters of the hash string to create the ID
  String id = '';
  for (int i = 0; i < 7; i++) {
    id += alphabet[hashString.codeUnitAt(i) % alphabet.length];
  }

  return id;
}

final userRepo = Provider<UserRepository>((ref) => UserRepository(ref: ref));
