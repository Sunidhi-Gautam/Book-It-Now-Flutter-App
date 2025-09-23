import 'package:flutter/material.dart';
import '../models/constants.dart';

class CinemaListScreen extends StatelessWidget {
  final String cityName;
  final List<Map<String, String>> cinemas;

  const CinemaListScreen({
    super.key,
    required this.cityName,
    required this.cinemas,
  });

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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    title: Text(
                      cinema['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(cinema['location'] ?? ''),
                    onTap: () {
                      // TODO: handle cinema selection
                    },
                  ),
                );
              },
            ),
    );
  }
}
