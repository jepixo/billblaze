import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billblaze/providers/firebase_providers.dart';
import 'package:billblaze/providers/auth_provider.dart';
import 'package:billblaze/providers/user_provider.dart';

class UserRepository {
  final ProviderRef<UserRepository> ref;

  UserRepository({
    required this.ref,
  });

  Future<void> sendFriendRequest(String recipientUid) async {
    final senderUid = createId(ref.read(authPr).currentUser!.email!);

    final firestore = ref.read(firestorePr);

    // Add the recipient's ID to the sender's friendRequestsSent collection
    await firestore
        .collection('users')
        .doc(senderUid)
        .collection('friendRequestsSent')
        .doc(recipientUid)
        .set({
      'recipientUid': recipientUid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await firestore
        .collection('users')
        .doc(recipientUid)
        .collection('friendRequestsReceived')
        .doc(senderUid)
        .set({
      'senderUid': senderUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(String senderUid) async {
    final recipientUid = createId(ref.read(authPr).currentUser!.email!);

    final firestore = ref.read(firestorePr);

    // Remove the friend request document from recipient's friendRequestsReceived collection
    await firestore
        .collection('users')
        .doc(recipientUid)
        .collection('friendRequestsReceived')
        .doc(senderUid)
        .delete();

    await firestore
        .collection('users')
        .doc(senderUid)
        .collection('friendRequestsSent')
        .doc(recipientUid)
        .delete();

    // Remove the friend request document from sender's friendRequestsSent collection

    // Add each other to the friend lists
    await firestore.runTransaction((transaction) async {
      final senderRef = firestore.collection('users').doc(senderUid);
      final recipientRef = firestore.collection('users').doc(recipientUid);

      transaction.update(senderRef, {
        'friendList': FieldValue.arrayUnion([recipientUid])
      });

      transaction.update(recipientRef, {
        'friendList': FieldValue.arrayUnion([senderUid])
      });
    });
  }

  Future<void> rejectFriendRequest(String senderUid) async {
    final recipientUid = createId(ref.read(authPr).currentUser!.email!);

    final firestore = ref.read(firestorePr);

    // Remove the friend request document from recipient's friendRequestsReceived collection
    await firestore
        .collection('users')
        .doc(recipientUid)
        .collection('friendRequestsReceived')
        .doc(senderUid)
        .delete();

    // Remove the recipient's ID from sender's friendRequestsSent collection
    await firestore
        .collection('users')
        .doc(senderUid)
        .collection('friendRequestsSent')
        .doc(recipientUid)
        .delete();

    // Check if the recipient is already in the sender's friend list
    final senderDoc = await firestore.collection('users').doc(senderUid).get();
    final senderFriendList = List<String>.from(senderDoc['friendList'] ?? []);

    if (senderFriendList.contains(recipientUid)) {
      // Remove the recipient from the sender's friend list
      await firestore.collection('users').doc(senderUid).update({
        'friendList': FieldValue.arrayRemove([recipientUid]),
      });
    }
  }
}
