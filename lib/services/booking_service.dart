// lib/services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wallet_manager.dart';

class BookingService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This function will handle the entire booking process
  static Future<bool> createBooking({
    required int movieId,
    required String movieTitle,
    required String bookingDetails,
    required List<String> selectedSeats,
    required int totalPrice,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in.");
      return false;
    }

    try {
      // Step 1: Attempt to make the purchase from the wallet
      bool paymentSuccessful =
          await WalletManager.makePurchase(totalPrice.toDouble());

      if (paymentSuccessful) {
        // Step 2: If payment is successful, create the booking record
        await _firestore.collection('bookings').add({
          'userId': user.uid,
          'movieId': movieId,
          'movieTitle': movieTitle,
          'bookingDetails': bookingDetails,
          'selectedSeats': selectedSeats,
          'totalPrice': totalPrice,
          'bookingTimestamp': FieldValue.serverTimestamp(),
        });

        print("Booking created successfully!");
        return true;
      } else {
        print("Payment failed. Insufficient funds or error.");
        return false;
      }
    } catch (e) {
      print("An error occurred during booking: $e");
      return false;
    }
  }
}
