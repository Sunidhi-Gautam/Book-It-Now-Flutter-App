import 'package:flutter/material.dart';
import '../models/constants.dart';

class SeatBookingPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const SeatBookingPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<SeatBookingPage> createState() => _SeatBookingPageState();
}

class _SeatBookingPageState extends State<SeatBookingPage> {
  // Use static const so we can safely use them in a field initializer.
  static const int rows = 5;
  static const int cols = 7;

  // Initialize the seatStatus matrix right away (rows x cols filled with 0).
  // 0 = available, 1 = reserved, 2 = selected
  final List<List<int>> seatStatus =
      List.generate(rows, (_) => List.generate(cols, (_) => 0));

  @override
  void initState() {
    super.initState();

    // Example reserved seats (safe because seatStatus already has correct shape)
    seatStatus[1][2] = 1;
    seatStatus[3][4] = 1;
  }

  int getSeatPrice(int row) {
    if (row >= 3) return 300;
    if (row == 2) return 200;
    return 100;
  }

  int get totalPrice {
    int total = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (seatStatus[r][c] == 2) total += getSeatPrice(r);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          widget.movieTitle,
          style: TextStyle(fontFamily: secondaryFonts),
        ),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Concave screen
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: const Center(
              child: Text(
                "SCREEN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                _legendBox(Colors.grey[700]!, "Available"),
                const SizedBox(width: 12),
                _legendBox(Colors.white, "Reserved"),
                const SizedBox(width: 12),
                _legendBox(Colors.red, "Selected"),
                const Spacer(),
                Text(
                  "Total: Rs. $totalPrice",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                final int r = index ~/ cols;
                final int c = index % cols;

                Color color;
                switch (seatStatus[r][c]) {
                  case 1:
                    color = Colors.white; // reserved
                    break;
                  case 2:
                    color = Colors.red; // selected
                    break;
                  default:
                    color = Colors.grey[700]!; // available
                }

                return GestureDetector(
                  onTap: seatStatus[r][c] != 1
                      ? () {
                          setState(() {
                            seatStatus[r][c] =
                                seatStatus[r][c] == 2 ? 0 : 2; // toggle selection
                          });
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: totalPrice == 0
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Proceed to pay Rs. $totalPrice')),
                  );
                },
          child: Text(
            "Pay Rs. $totalPrice",
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // small helper for legend
  Widget _legendBox(Color color, String text) {
    return Row(
      children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
