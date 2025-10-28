// lib/services/credits_manager.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

class CreditsManager {
  static final _db = FirebaseFirestore.instance; 
  
  /// Returns a stream of the user's current credits.
  static Stream<int> getCreditsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value(0); // Return 0 if no user is logged in
    }

    //  Return a real stream from Firestore
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return 0; // Return 0 if document doesn't exist
      }
      // Read the 'credits' field, default to 0 if it's null
      return (doc.data()!['credits'] as num?)?.toInt() ?? 0;
    });
  }

  /// Adds a specified amount of credits to the user's account.
  static Future<void> addCredits(int amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // Not logged in

    final docRef = _db.collection('users').doc(uid);

    //  Atomically add the value to the 'credits' field
    await docRef.update({'credits': FieldValue.increment(amount)});
  }

  /// Spends a specified amount of credits.
  static Future<void> spendCredits(int amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _db.collection('users').doc(uid);
    
    // Atomically subtract the value
    await docRef.update({'credits': FieldValue.increment(-amount)});
  }
}