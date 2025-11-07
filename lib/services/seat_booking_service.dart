import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance;

  /// ✅ Save booking under theatre → show → bookedSeats
  static Future<bool> bookSeats({
    required String theatreId,
    required String showId,
    required List<String> seats,      // ["A1","A2"]
    required int movieId,
    required String movieTitle,
  }) async {
    final showRef = _db
        .collection("theatres")
        .doc(theatreId)
        .collection("shows")
        .doc(showId);

    return _db.runTransaction((transaction) async {
      final showSnap = await transaction.get(showRef);

      List booked = [];

      if (showSnap.exists) {
        booked = List<String>.from(showSnap.data()?["bookedSeats"] ?? []);
      }

      // ✅ Check seat conflict
      for (var seat in seats) {
        if (booked.contains(seat)) {
          throw Exception("Seat $seat already booked!");
        }
      }

      // ✅ Merge new seats with old ones
      booked.addAll(seats);

      transaction.set(
        showRef,
        {
          "movieId": movieId,
          "movieTitle": movieTitle,
          "bookedSeats": booked,
        },
        SetOptions(merge: true),
      );
    }).then((value) => true).catchError((e) {
      print("BOOKING ERROR: $e");
      return false;
    });
  }

  /// ✅ Get booked seats for the show
  static Future<List<String>> getBookedSeats({
    required String theatreId,
    required String showId,
  }) async {
    final snap = await _db
        .collection("theatres")
        .doc(theatreId)
        .collection("shows")
        .doc(showId)
        .get();

    if (!snap.exists) return [];

    return List<String>.from(snap.data()?["bookedSeats"] ?? []);
  }
}
