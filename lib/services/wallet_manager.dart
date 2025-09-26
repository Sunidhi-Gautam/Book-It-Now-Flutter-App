// lib/services/wallet_manager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This helper function is good, no changes needed here.
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
        'username': username, // <-- SAVE THE USERNAME HERE
        'walletBalance': 1000.0, // Starting balance
        'createdAt': FieldValue.serverTimestamp(), // Good practice to add a timestamp
      });
    }
  }

  // CHANGE: Added explicit type casting for safety.
  static Stream<double> getBalanceStream() {
    final docRef = _userDocRef;
    if (docRef == null) return Stream.value(0.0);
    
    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return 0.0;
      
      // Explicitly cast the data to a Map
      final data = snapshot.data() as Map<String, dynamic>;
      
      // Safely access the value
      return (data['walletBalance'] as num? ?? 0.0).toDouble();
    });
  }

  // CHANGE: Added explicit type casting inside the transaction.
  static Future<bool> makePurchase(double amount) async {
    final docRef = _userDocRef;
    if (docRef == null) return false;

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists || snapshot.data() == null) {
          throw Exception("User document does not exist!");
        }

        // Explicitly cast the data to a Map
        final data = snapshot.data() as Map<String, dynamic>;
        final currentBalance = (data['walletBalance'] as num? ?? 0.0).toDouble();

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

