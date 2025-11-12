// lib/services/wallet_manager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static DocumentReference? get _userDocRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  static Future<void> createUserWallet({required String username}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'email': user.email,
        'username': username,
        'walletBalance': 1000.0,
        'createdAt': FieldValue.serverTimestamp(),
        'credits': 500,
      });
    }
  }

  static Stream<double> getBalanceStream() {
    final docRef = _userDocRef;
    if (docRef == null) return Stream.value(0.0);

    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return 0.0;

      final data = snapshot.data() as Map<String, dynamic>;
      return (data['walletBalance'] as num? ?? 0.0).toDouble();
    });
  }

  // Adds credits to the user's wallet
  static Future<bool> addCredits(double amount) async {
    final docRef = _userDocRef;
    if (docRef == null || amount <= 0) {
      return false;
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists || snapshot.data() == null) {
          throw Exception("User document does not exist!");
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final currentBalance =
            (data['walletBalance'] as num? ?? 0.0).toDouble();

        // Calculate the new balance by adding the amount
        final newBalance = currentBalance + amount;

        transaction.update(docRef, {'walletBalance': newBalance});
      });
      return true;
    } catch (e) {
      print("Failed to add credits: $e");
      return false;
    }
  }

  static Future<bool> makePurchase(double amount) async {
    final docRef = _userDocRef;
    if (docRef == null) return false;

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists || snapshot.data() == null) {
          throw Exception("User document does not exist!");
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final currentBalance =
            (data['walletBalance'] as num? ?? 0.0).toDouble();

        if (currentBalance < amount) {
          throw Exception("Insufficient funds!");
        }

        transaction.update(docRef, {'walletBalance': currentBalance - amount});
      });
      return true;
    } catch (e) {
      print("Transaction failed: $e");
      return false;
    }
  }
}
