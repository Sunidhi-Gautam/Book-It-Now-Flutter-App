import 'package:flutter/material.dart';
import '../models/constants.dart';
import 'seatSelections.dart';



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
        title: Text("Cinemas in $cityName", style: const TextStyle(color: Colors.white)),
        backgroundColor: kPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: cinemas.isEmpty
            ? const Center(child: Text("No cinemas found"))
            : ListView.separated(
                itemCount: cinemas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cinema = cinemas[index];
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kPrimary,
                      side: BorderSide(color: kPrimary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Seatselections(movieId: 1 , movieTitle: '',
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cinema['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(cinema['location']!, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
