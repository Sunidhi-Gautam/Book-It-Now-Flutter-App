// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'homepage.dart';
import 'review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          " All Set for Movie Mayhem!",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        // centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePageScreen()),
              );
            },
          ),
        ],
      ),

      // 🔥 Fetch bookings from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No bookings yet",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.black.withOpacity(0.9),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => BookingDetailsSheet(
                      booking: booking,
                      bookingId: bookings[index].id,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(booking['posterUrl']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.45), BlendMode.darken),
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['movieTitle'],
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${booking['cinemaName'] ?? ''}, ${booking['cinemaLocation'] ?? ''}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking['showTime'] ?? "Date not available",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookingDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String bookingId;

  const BookingDetailsSheet({
    super.key,
    required this.booking,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 6,
              width: 60,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3)),
            ),

            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                booking['posterUrl'],
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              booking['movieTitle'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // Combined Cinema Info
            infoRow(
              "📍 Cinema",
              "${booking['cinemaName'] ?? "Unknown Cinema"}, ${booking['cinemaLocation'] ?? "Location not available"}",
            ),
            infoRow("🗓 Date & Time", booking['showTime'] ?? "Not available"),
            infoRow(
                "💺 Seats",
                (booking['selectedSeats'] != null &&
                        booking['selectedSeats'].isNotEmpty)
                    ? booking['selectedSeats'].join(", ")
                    : "Not selected"),
            infoRow(
                "💰 Paid",
                booking['totalPrice'] != null
                    ? "Rs. ${booking['totalPrice']}"
                    : "Not available"),
            const SizedBox(height: 14),

            // QR Code Section
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: SfBarcodeGenerator(
                    value: (booking['bookingId'] ?? "000000").toString(),
                    symbology: QRCode(),
                    showValue: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "Booking ID: $bookingId",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // --- Review Button Logic (Enhanced) ---
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (context) {
                  DateTime? showTime;

                  // Handle Firestore Timestamp or String
                  final rawTime = booking['showTime'];
                  if (rawTime is Timestamp) {
                    showTime = rawTime.toDate();
                  } else if (rawTime is String) {
                    try {
                      // Example: "Fri, Oct 31 - 1:00 PM"
                      final regex = RegExp(
                          r'([A-Za-z]{3}), ([A-Za-z]{3}) (\d{1,2}) - (\d{1,2}):(\d{2}) ([APMapm]{2})');
                      final match = regex.firstMatch(rawTime);

                      if (match != null) {
                        final monthAbbrev = match.group(2)!; // Oct
                        final day = int.parse(match.group(3)!); // 31
                        final hour = int.parse(match.group(4)!); // 1
                        final minute = int.parse(match.group(5)!); // 00
                        final period = match.group(6)!.toUpperCase(); // PM

                        // Map short month to number
                        const months = {
                          'Jan': 1,
                          'Feb': 2,
                          'Mar': 3,
                          'Apr': 4,
                          'May': 5,
                          'Jun': 6,
                          'Jul': 7,
                          'Aug': 8,
                          'Sep': 9,
                          'Oct': 10,
                          'Nov': 11,
                          'Dec': 12
                        };
                        final month = months[monthAbbrev] ?? 1;

                        // Adjust 12-hour to 24-hour format
                        int hour24 = hour % 12;
                        if (period == 'PM') hour24 += 12;

                        // Use current year
                        final now = DateTime.now();
                        showTime =
                            DateTime(now.year, month, day, hour24, minute);
                      }
                    } catch (e) {
                      print('❌ Date parse failed for $rawTime → $e');
                    }
                  }

                  final now = DateTime.now();
                  final hasShowStarted =
                      showTime != null && now.isAfter(showTime);
                  final isReviewed = booking['reviewed'] == true;

                  final isButtonEnabled = hasShowStarted;

                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey; // color when disabled
                          }
                          return const Color.fromARGB(
                              255, 65, 2, 2); // normal color
                        },
                      ),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    onPressed: isButtonEnabled
                        ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewPage(
                                  bookingId: booking['bookingId'],
                                ),
                              ),
                            );
                            if (result == true) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('bookings')
                                    .doc(bookingId)
                                    .update({'reviewed': true});
                              }
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    child: Text(
                      isReviewed
                          ? "Reviewed"
                          : isButtonEnabled
                              ? "Review"
                              : "Review (Available after Show)",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon,
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
