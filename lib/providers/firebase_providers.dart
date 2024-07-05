import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:billblaze/providers/auth_provider.dart';

// final usernameProvider = StateProvider<String>((ref) => '');
final firestorePr = Provider((ref) => FirebaseFirestore.instance);

final querySnapshotPr = StateProvider((ref) => ref
    .read(firestorePr)
    .collection("users")
    .where("email", isEqualTo: ref.read(authPr).currentUser?.email));
      // .get()) ;