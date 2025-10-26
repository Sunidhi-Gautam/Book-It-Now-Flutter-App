// seat_selection_screen.dart
// lib/services/booking_service.dart

import 'package:book_my_seat/book_my_seat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Assuming 'constants.dart' defines kPrimaryColorColor
import '../models/constants.dart';
import '../services/booking_service.dart';
import 'ticket_generate.dart';

// --- PRICE CONSTANTS (Unchanged) ---
const int _priceClassic = 200;
const int _pricePrime = 350;

int _getPriceByRowIndex(int absoluteRowIndex) {
  if (absoluteRowIndex >= 0 && absoluteRowIndex <= 7) return _priceClassic;
  if (absoluteRowIndex >= 8 && absoluteRowIndex <= 9) return _pricePrime;
  return 0;
}
// ----------------------------

class SeatSelectionScreen extends StatefulWidget {
  final int movieId;
  // Expected Format: "Movie Title - Cinema Name, City Name (Day, Date - Time)"
  final String bookingDetailsTitle;
  final String movieTitle;
  final String cinemaName;
  final String cinemaLocation;
  final String dateTime;
  final List<String> castList;

  const SeatSelectionScreen({
    super.key,
    required this.movieId,
    required this.bookingDetailsTitle,
    required this.movieTitle,
    required this.cinemaName,
    required this.cinemaLocation,
    required this.dateTime,
    required this.castList,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  Set<SeatNumber> selectedSeats = {};
  int _nextRowLabelIndex = 0;
  int _totalPrice = 0;
  bool _isProcessing = false; // for payment processing state

  String _getRowLabel(int index) {
    return String.fromCharCode(65 + index);
  }

  void _calculateTotalPrice() {
    int total = 0;
    for (var seat in selectedSeats) {
      total += seat.price;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  // 💡 FIX: Updated parsing logic to handle "Cinema Name, City Name (Day, Date - Time)"
  Map<String, String> _parseBookingDetails() {
    final fullTitle = widget.bookingDetailsTitle;

    // 1. Extract the Movie Title (everything before the first ' - ')
    final titleParts = fullTitle.split(' - ');
    String movieTitle =
        titleParts.isNotEmpty ? titleParts.first.trim() : widget.movieTitle;

    // The remaining string contains the cinema, location, and date/time.
    // Example: "INOX, Delhi (Thu, Sep 25 - 10:00 AM)"
    String remainingString = fullTitle.substring(movieTitle.length + 3).trim();

    // Regex to capture "Cinema Details" (Group 1) and the content inside the parentheses (Group 2: Date and Time)
    final regex = RegExp(r'^(.*?)\s\((.*?)\)$');
    final match = regex.firstMatch(remainingString);

    String cinemaDetailsSubtitle = "N/A";
    String showDateTime = "N/A"; // This will hold "Day, Date - Time"

    if (match != null && match.groupCount == 2) {
      // Group 1: Cinema Name, City Name (e.g., "INOX, Delhi")
      cinemaDetailsSubtitle = match.group(1)?.trim() ?? "N/A";
      // Group 2: Day, Date - Time (e.g., "Thu, Sep 25 - 10:00 AM")
      showDateTime = match.group(2)?.trim() ?? "N/A";
    }
    // If regex fails, use existing logic as a fallback (less reliable)
    else {
      cinemaDetailsSubtitle =
          remainingString.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      // Try to find the time/date in parentheses manually if regex failed
      final timeMatch = RegExp(r'\((.*?)\)$').firstMatch(remainingString);
      showDateTime = timeMatch?.group(1)?.trim() ?? "N/A";
    }

    // Now, showDateTime holds the full string, including Day and Date.
    return {
      'movieTitle': movieTitle,
      'cinemaDetailsSubtitle': cinemaDetailsSubtitle,
      // The full string including Day and Date is used for the banner.
      'showTime': showDateTime,
    };
  }

  Widget _buildSectionTitle(String title, int price) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      color: const Color.fromARGB(255, 15, 14, 14),
      child: Text(
        '$title: Rs. $price',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color.fromARGB(
              255, 128, 125, 125), // Using a dark color for contrast
        ),
      ),
    );
  }

  // bookings

  Future<void> _handleBooking() async {
    if (selectedSeats.isEmpty) return;

    setState(() {
      _isProcessing = true; // Show loading indicator
    });

    // Convert selected seats to a simple list of strings like ["A1", "J5"]
    final seatStrings =
        selectedSeats.map((seat) => seat.toSeatString(_getRowLabel)).toList();

    // Call the booking service
    // ignore: unused_local_variable
    bool success = await BookingService.createBooking(
      movieId: widget.movieId,
      movieTitle: widget.movieTitle,
      bookingDetails: widget.bookingDetailsTitle,
      selectedSeats: seatStrings,
      totalPrice: _totalPrice,
    );

    // Hide loading indicator
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _isProcessing = false;
      });
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketPage(
          movieId: widget.movieId,
          movieTitle: widget.movieTitle,
          cinemaName: widget.cinemaName,
          cinemaLocation: widget.cinemaLocation,
          showTime: widget.dateTime,
          selectedSeats: seatStrings,
          totalPrice: _totalPrice,
          castList: widget.castList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _nextRowLabelIndex = 0;
    final details = _parseBookingDetails();
    final movieTitle = details['movieTitle']!;
    final cinemaDetailsSubtitle = details['cinemaDetailsSubtitle']!;
    final showTime = details['showTime']!; // This is now "Day, Date - Time"

    // Helper to build a section, update the index, and return the widgets
    List<Widget> buildSectionAndUpdate({
      required int rows,
      required int cols,
      required List<List<SeatState>> seatStates,
    }) {
      final widgets = buildSeatSection(
        startRowIndex: _nextRowLabelIndex,
        rows: rows,
        cols: cols,
        seatStates: seatStates,
      );
      _nextRowLabelIndex += rows;
      return widgets;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movieTitle,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: secondaryFonts),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              cinemaDetailsSubtitle, // e.g., "INOX, Delhi"
              style: const TextStyle(fontSize: 15, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: kPrimaryColor, // Assuming kPrimaryColor is defined
        foregroundColor: const Color.fromARGB(255, 254, 254, 254),
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Show Time Banner - Now displays full date and time
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: Colors.red[50],
                child: Center(
                  child: Text(
                    // FIX: showTime now contains Day and Date
                    'Show Time: $showTime', // Output: "Show Time: Thu, Sep 25 - 10:00 AM"
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              const Text(
// ... (rest of the build function remains the same)
// ...
                "Screen This Way",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(
                width: double.infinity,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/theatre_screen_image.png',
                      fit: BoxFit.cover,
                      width: 400,
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('CLASSIC', _priceClassic),
              const SizedBox(height: 5),

              /// Section 1-A (Rows A, B, C, D)
              ...buildSectionAndUpdate(
                rows: 4,
                cols: 10,
                seatStates: [
                  [
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected
                  ],
                  [
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected
                  ],
                  [
                    SeatState.sold,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected
                  ],
                  [
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected
                  ],
                ],
              ),

              const SizedBox(height: 18),

              /// Section 1-B (Rows E, F, G, H) - Part of CLASSIC
              ...buildSectionAndUpdate(
                rows: 4,
                cols: 10,
                seatStates: [
                  [
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected
                  ],
                  [
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected
                  ],
                  [
                    SeatState.sold,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected
                  ],
                  [
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected
                  ],
                ],
              ),

              const SizedBox(height: 18),

              _buildSectionTitle('PRIME', _pricePrime),
              const SizedBox(height: 10),

              /// Section 2 (Rows I, J)
              ...buildSectionAndUpdate(
                rows: 2,
                cols: 10,
                seatStates: [
                  [
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected
                  ],
                  [
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.sold,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.unselected,
                    SeatState.disabled,
                    SeatState.unselected
                  ],
                ],
              ),

              const SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    legendItem(
                        'Disabled', 'assets/images/svg_disabled_bus_seat.svg'),
                    legendItem('Sold', 'assets/images/svg_sold_bus_seat.svg'),
                    legendItem('Available',
                        'assets/images/svg_unselected_bus_seat.svg'),
                    legendItem('Selected by you',
                        'assets/images/svg_selected_bus_seats.svg'),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              Text(
                'Selected Seats: ${selectedSeats.isEmpty ? "None" : selectedSeats.map((s) => s.toSeatString(_getRowLabel)).join(" , ")}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 10),

              // --- BUTTON DYNAMICALLY SHOWS PRICE ---

              ElevatedButton(
                onPressed: (_totalPrice > 0 && !_isProcessing)
                    ? _handleBooking
                    : null, // Call the handler
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  disabledBackgroundColor: Colors.grey,
                  shadowColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        // Show a spinner when processing
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        // Show regular text otherwise
                        _totalPrice > 0
                            ? 'Proceed to Pay Rs. $_totalPrice'
                            : 'Select Seats to Proceed',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable function to build the seat section row-by-row with labels (Unchanged)
  List<Widget> buildSeatSection({
    required int startRowIndex,
    required int rows,
    required int cols,
    required List<List<SeatState>> seatStates,
  }) {
    return List.generate(rows, (rowIndex) {
      final absoluteRowIndex = startRowIndex + rowIndex;
      final rowLabel = _getRowLabel(absoluteRowIndex);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                rowLabel,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 249, 249, 249),
                ),
              ),
            ),
            const SizedBox(width: 25),
            Center(
              child: SeatLayoutWidget(
                onSeatStateChanged: (localRowI, colI, seatState) {
                  final seatPrice = _getPriceByRowIndex(absoluteRowIndex);
                  final seatNumber = SeatNumber(
                    rowI: absoluteRowIndex,
                    colI: colI,
                    price: seatPrice,
                  );

                  if (seatState == SeatState.selected) {
                    selectedSeats.add(seatNumber);
                  } else {
                    selectedSeats.remove(seatNumber);
                  }

                  _calculateTotalPrice();
                },
                stateModel: SeatLayoutStateModel(
                  currentSeatsState: [seatStates[rowIndex]],
                  pathDisabledSeat: 'assets/images/svg_disabled_bus_seat.svg',
                  pathSelectedSeat: 'assets/images/svg_selected_bus_seats.svg',
                  pathSoldSeat: 'assets/images/svg_sold_bus_seat.svg',
                  pathUnSelectedSeat:
                      'assets/images/svg_unselected_bus_seat.svg',
                  rows: 1,
                  cols: cols,
                  seatSvgSize: 28,
                ),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 20,
              child: Text(
                rowLabel,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget legendItem(String label, String assetPath) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(assetPath, width: 17, height: 17),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }
}

// --- SeatNumber CLASS (Unchanged) ---
class SeatNumber {
  final int rowI;
  final int colI;
  final int price;

  const SeatNumber(
      {required this.rowI, required this.colI, required this.price});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatNumber && rowI == other.rowI && colI == other.colI;

  @override
  int get hashCode => Object.hash(rowI, colI);

  String toSeatString(String Function(int) getRowLabel) {
    final rowLetter = getRowLabel(rowI);
    return '$rowLetter${colI + 1}';
  }
}
