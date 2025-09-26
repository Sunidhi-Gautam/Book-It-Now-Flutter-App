// cinema_list.dart (UPDATED to StatefulWidget)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/ticketbooking/showTiming.dart';
import '../models/constants.dart';
import 'seat_selection_screen.dart';


class CinemaListScreen extends StatefulWidget {
  final String cityName;
  final List<Map<String, String>> cinemas;
  final int movieId;
  final String movieTitle;

  const CinemaListScreen({
    super.key,
    required this.cityName,
    required this.cinemas,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<CinemaListScreen> createState() => _CinemaListScreenState();
}

class _CinemaListScreenState extends State<CinemaListScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<String> showTimings = const [
    "10:00 AM",
    "1:00 PM",
    "4:00 PM",
    "7:00 PM",
    "10:00 PM",
  ];

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // You could also refresh the cinema list here if showtimes were dynamic
  }

  @override
  Widget build(BuildContext context) {
    // Determine the formatted date/day string to pass to the next screen
    final selectedDayAndDate = DateFormat('EEE, MMM dd').format(_selectedDate); // e.g., "Thu, Sep 25"

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      appBar: AppBar(
        backgroundColor: kPrimaryColorColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${widget.cityName} Cinemas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: secondaryFonts
          ),
        ),
      ),

      // Wrap the content in a Column to add the date selector on top
      body: Column(
        children: [
          // 1. SHOW TIMING SELECTOR
          ShowTimingSelector(
            movieIndex: widget.movieId, // Using movieId as index, adjust if necessary
            onDateSelected: _handleDateSelected,
          ),

          // 2. CINEMA LIST
          Expanded(
            child: widget.cinemas.isEmpty
                ? Center(
                    child: Text(
                      "No cinemas with valid locations found.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: secondaryFonts, color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.cinemas.length,
                    itemBuilder: (context, index) {
                      final cinema = widget.cinemas[index];
                      final cinemaNameAndLocation =
                          "${cinema['name'] ?? 'Cinema'}, ${widget.cityName}";

                      return Card(
                        color: const Color.fromARGB(255, 36, 36, 36),
                        shadowColor: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red, size: 22),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      cinemaNameAndLocation,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: secondaryFonts,
                                        color: Colors.white 
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
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontFamily: secondaryFonts
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
                                      backgroundColor: const Color.fromARGB(255, 190, 188, 188),
                                      foregroundColor: const Color.fromARGB(255, 15, 13, 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      // PASSING the selected date and day to SeatSelectionScreen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SeatSelectionScreen(
                                            movieId: widget.movieId,
                                            // New format: "Movie Title - Cinema, City (Day, Date - Time)"
                                            bookingDetailsTitle:
                                                "${widget.movieTitle} - $cinemaNameAndLocation ($selectedDayAndDate - $time)",
                                            movieTitle: widget.movieTitle,
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
          ),
        ],
      ),
    );
  }
}