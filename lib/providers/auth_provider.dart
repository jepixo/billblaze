import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:billblaze/auth/user_auth.dart';

final googleSigninPr = Provider((ref) => GoogleSignIn());
final authPr = Provider((ref) => FirebaseAuth.instance);
final authRepositoryProvider = StateProvider((ref) {
  return AuthRepository(
      auth: ref.read(authPr), googleSignIn: ref.read(googleSigninPr));
});
