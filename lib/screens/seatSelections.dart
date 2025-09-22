import '../components/seatselections/seatListing.dart';
import '../models/constants.dart';
import 'package:flutter/material.dart';

class Seatselections extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const Seatselections({super.key, required this.movieId, required this.movieTitle});

  @override
  State<Seatselections> createState() => _SeatselectionsState();
}

class _SeatselectionsState extends State<Seatselections> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movieTitle,
              style: TextStyle(
                  color: darkColor, fontSize: textContent, fontFamily: primaryFont),
            ),
            const Text(
              'Cinepolis Mumbai, Maharashtra',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black), // back button color
      ),
      backgroundColor: Colors.white,
      body: const PaymentScreen(), // show your seat selection grid
    );
  }
}
