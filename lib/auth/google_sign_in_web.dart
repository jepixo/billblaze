// import 'package:billblaze/providers/authProvider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class GoogleSignInWeb {
//   Future<void> googleLoginWeb(WidgetRef ref) async {
//     // Web-specific Google login implementation
//     try {
//       GoogleAuthProvider authProvider = GoogleAuthProvider();
//       await ref.read(authPr).signInWithPopup(authProvider);
//     } catch (e) {
//       return;
//     }
//   }

//   Future<void> signOut() async {
//     await FirebaseAuth.instance.signOut();
//   }
// }
