import 'package:billblaze/providers/env_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:billblaze/auth/user_auth.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart' as gap;

final googleSigninPr = Provider((ref) => GoogleSignIn());
final googleSignInProvider = StateProvider<gap.GoogleSignIn>((ref) {
  return gap.GoogleSignIn(
    params: gap.GoogleSignInParams(
      clientId: gSignInClientId,
      clientSecret: gSignInClientSecret,
      redirectPort: 3000,
    ),
  );
});

final authPr = Provider((ref) => FirebaseAuth.instance);
final authRepositoryProvider = StateProvider((ref) {
  return AuthRepository(
      auth: ref.read(authPr), googleSignIn: ref.read(googleSigninPr));
});
final authTokenManagerProvider = StateProvider<AuthTokenManager>((ref) {
  return AuthTokenManager();
});
final gapSignInProvider = StateProvider<gap.GoogleSignIn>((ref) {
  return gap.GoogleSignIn(
    params: gap.GoogleSignInParams(
      clientId: gSignInClientId,
      clientSecret: gSignInClientSecret,
      redirectPort: 3000,
      scopes: [
        'email',
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/drive',
        'https://www.googleapis.com/auth/spreadsheets',
        'https://www.googleapis.com/auth/documents',
      ],
    ),
  );
});

// providers.dart
final authStateStreamProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);


