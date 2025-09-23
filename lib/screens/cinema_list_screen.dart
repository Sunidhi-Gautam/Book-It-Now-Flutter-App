import 'package:flutter/material.dart';
import '../models/constants.dart';
import 'seatSelections.dart';

class CinemaListScreen extends StatelessWidget {
  final String cityName;
  final List<Map<String, String>> cinemas;
  final int movieId; // pass movieId from previous screen
  final String movieTitle; // pass movie title

  const CinemaListScreen({
    super.key,
    required this.cityName,
    required this.cinemas,
    required this.movieId,
    required this.movieTitle,
  });

  // Example show timings (you can also fetch dynamically later)
  final List<String> showTimings = const [
    "10:00 AM",
    "1:00 PM",
    "4:00 PM",
    "7:00 PM",
    "10:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "$cityName Cinemas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: secondaryFonts,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: cinemas.isEmpty
          ? const Center(
              child: Text(
                "No cinemas with valid locations found.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              itemCount: cinemas.length,
              itemBuilder: (context, index) {
                final cinema = cinemas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cinema Info
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 22),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cinema['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (cinema['location'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 28),
                            child: Text(
                              cinema['location']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Timings row
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: showTimings.map((time) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Navigate to SeatBookingPage with cinema & time
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SeatBookingPage(
                                      movieId: movieId,
                                      movieTitle:
                                          "$movieTitle - ${cinema['name']} ($time)",
                                    ),
                                  ),
                                );
                              },
                              child: Text(time),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
