import 'dart:async';
import 'dart:convert';
import 'package:billblaze/providers/env_provider.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:platform/platform.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:billblaze/providers/firebase_providers.dart';
// Comment for web
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart'
    as gap;

enum AuthResult { success, abort, failed, sleep }

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final Platform _platform;

  AuthRepository({
    required auth,
    required googleSignIn,
    Platform? platform,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _platform = platform ?? const LocalPlatform();

  Future<void> googleLogin(WidgetRef ref) async {
    if (kIsWeb) {
      await _googleLoginWeb();
    } else if (_platform.isAndroid) {
      await _googleLoginAndroid(ref);
    } else if (_platform.isWindows) {
      await _googleLoginWindows(ref);
    }
  }

  Future<void> _googleLoginWeb() async {
    // Web-specific Google login implementation
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      await _auth.signInWithPopup(authProvider);
    } catch (e) {
      return;
    }
  }

  Future<void> _googleLoginAndroid(WidgetRef ref) async {
    // Android-specific Google login implementation
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    try {
      await _auth.signInWithCredential(credential);
    } catch (e) {
      return;
    }
  }

  Future<void> _googleLoginWindows(WidgetRef ref) async {
    final gap.GoogleSignIn _googleSignIn = ref.read(googleSignInProvider);

    try {
      final creds = await _googleSignIn.signInOnline();
      if (creds == null) {
        print('Could not sign in');
        return;
      }
      //  ref.read(authCredentialsProvider.notifier).update((state) => creds,);
      // Now, sign in with Firebase using the obtained credentials

      final credential = GoogleAuthProvider.credential(
        accessToken: creds.accessToken,
        idToken: creds.idToken,
      );

      // Sign in with Firebase using the Google credentials
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('Signed in successfully: ${userCredential.user}');
    } catch (e) {
      print('Error signing in with Google: $e');
      // Handle error here
    }
  } //
  //
  /// Sign in with email + password
  Future<AuthResult> emailPasswordSignIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) return AuthResult.abort;

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        print('Email/password sign-in success: ${userCredential.user!.email}');
        return AuthResult.success;
      } else {
        return AuthResult.failed;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException in emailPasswordSignIn: ${e.code} ${e.message}');
      return AuthResult.failed;
    } catch (e, st) {
      print('Unexpected error in emailPasswordSignIn: $e\n$st');
      return AuthResult.failed;
    }
  }
  
  Future<void> googleLogOut(WidgetRef ref) async {
  try {
    final googleSignIn = ref.read(googleSignInProvider);
    await googleSignIn.signOut(); // Sign out from Google
    await ref.read(authPr).signOut(); // Sign out from FirebaseAuth
    print('Signed out successfully');
  } catch (e, st) {
    print('Error signing out: $e');
    print(st);
  }
}

  Future<String> promptForUsername(BuildContext context) async {
    String username = '';

    final user = FirebaseAuth.instance.currentUser;
    String emailPrefix = user!.email!.split('@')[0];
    username = '$emailPrefix';

    return username;
  }

  Future<void> checkAndCreateUserDocument(context, WidgetRef ref) async {
    final user = ref.read(authPr).currentUser;
    if (user == null || user.email == null) {
      return;
    }
    final QuerySnapshot querySnapshot = await ref
        .read(firestorePr)
        .collection("users")
        .where("email", isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> userData =
          querySnapshot.docs[0].data() as Map<String, dynamic>;
      String? username = userData['username'] as String?;
      if (username != null) {
        // ref.read(usernameProvider.notifier).update((state) => username);
      }
      return;
    }

    String username = await promptForUsername(context);
    bool isUsernameTaken = true;

    while (isUsernameTaken) {
      final usernameQuerySnapshot = await ref
          .read(firestorePr)
          .collection("users")
          .where("username", isEqualTo: username)
          .get();

      if (usernameQuerySnapshot.docs.isNotEmpty) {
        username = await promptForUsername(context);
      } else {
        // ref.read(usernameProvider.notifier).update((state) => username);
        String id = createId(user.email!);
        await ref.read(firestorePr).collection("users").doc(id).set({
          "id": id,
          "username": username,
          "email": user.email,
          "latitude": 0.0,
          "longitude": 0.0,
          "photoUrl": user.photoURL
        });
        // ref.read(usernameProvider.notifier).update((state) => username);
      }
      isUsernameTaken = false;
    }
  }

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
}

class AuthTokenManager {
  final gap.GoogleSignInCredentials? credentials;
  final DateTime? expiryTime;

  const AuthTokenManager({this.credentials, this.expiryTime});

  bool get isValid =>
      credentials != null &&
      expiryTime != null &&
      DateTime.now().isBefore(expiryTime!);
}
