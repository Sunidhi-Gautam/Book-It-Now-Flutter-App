import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import '../models/constants.dart';
import 'cinema_list_screen.dart';

class SelectLocationScreen extends StatelessWidget {
  const SelectLocationScreen({super.key});

  final List<Map<String, dynamic>> cities = const [
    {'name': 'Delhi', 'lat': 28.6139, 'lng': 77.2090},
    {'name': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Chennai', 'lat': 13.0827, 'lng': 80.2707},
    {'name': 'Kolkata', 'lat': 22.5726, 'lng': 88.3639},
  ];

  Future<List<Map<String, String>>> fetchCinemas(
      double lat, double lng, String cityName) async {
    final query = '''
      [out:json][timeout:25];
      (
        node["amenity"="cinema"](around:5000,$lat,$lng);
        way["amenity"="cinema"](around:5000,$lat,$lng);
        relation["amenity"="cinema"](around:5000,$lat,$lng);
      );
      out center;
    ''';

    final url = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    final elements = data['elements'] as List<dynamic>;

    final cinemas = elements
        .where((e) => e['tags'] != null && e['tags']['name'] != null)
        .map<Map<String, String>>((e) {
      final tags = e['tags'] as Map<String, dynamic>;

      // Collect all possible address parts
      List<String> parts = [];
      if (tags['addr:street'] != null) parts.add(tags['addr:street']);
      if (tags['addr:suburb'] != null) parts.add(tags['addr:suburb']);
      if (tags['addr:district'] != null) parts.add(tags['addr:district']);
      if (tags['addr:city'] != null) parts.add(tags['addr:city']);

      final location = parts.join(", "); // Combine available parts

      return {
        'name': tags['name'].toString(),
        'location': location,
      };
    })
        // ✅ Only keep cinemas with at least one location field
        .where((c) => c['location'] != null && c['location']!.isNotEmpty)
        .toList();

    return cinemas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Select Location",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: secondaryFonts,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: cities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final city = cities[index];
            return GestureDetector(
              onTap: () async {
                // Show loading while fetching cinemas
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );

                final cinemas = await fetchCinemas(
                  city['lat'],
                  city['lng'],
                  city['name'],
                );
                Navigator.pop(context); // close loading dialog

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CinemaListScreen(
                      cityName: city['name'],
                      cinemas: cinemas,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimary, width: 2),
                ),
                child: Center(
                  child: Text(
                    city['name'],
                    style: TextStyle(
                      color: kPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
