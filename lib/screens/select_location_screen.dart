// SelectLocationScreen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
// Assuming 'constants.dart' defines kPrimaryColor and secondaryFonts
import '../models/constants.dart'; 
import 'cinema_list_screen.dart';

class SelectLocationScreen extends StatelessWidget {
  final int movieId; // receive movieId from previous screen
  final String movieTitle; // receive movieTitle from previous screen

  const SelectLocationScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  // 💡 UPDATED: Added an 'image' path for each city
  final List<Map<String, dynamic>> cities = const [
    {
      'name': 'Delhi', 
      'lat': 28.6139, 
      'lng': 77.2090, 
      'image': 'assets/images/delhi.png' // Ensure this path is correct
    },
    {
      'name': 'Mumbai', 
      'lat': 19.0760, 
      'lng': 72.8777, 
      'image': 'assets/images/mumbai.png', // Ensure this path is correct
    },
    {
      'name': 'Chennai', 
      'lat': 13.0827, 
      'lng': 80.2707, 
      'image': 'assets/images/chennai.png' // Ensure this path is correct
    },
    {
      'name': 'Kolkata', 
      'lat': 22.5726, 
      'lng': 88.3639, 
      'image': 'assets/images/kolkata.png' // Ensure this path is correct
    },
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
      if (tags['addr:street'] != null) parts.add(tags['addr:street'].toString());
      if (tags['addr:suburb'] != null) parts.add(tags['addr:suburb'].toString());
      if (tags['addr:district'] != null) parts.add(tags['addr:district'].toString());
      if (tags['addr:city'] != null) parts.add(tags['addr:city'].toString());

      final location = parts.join(", "); // Combine available parts

      return {
        'name': tags['name'].toString(),
        'location': location,
      };
    })
        // Only keep cinemas with at least one location field
        .where((c) => c['location'] != null && c['location']!.isNotEmpty)
        .toList();

    return cinemas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color:Colors.white,),
        title: Text(
          "Select Location",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: secondaryFonts,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      body : Center(child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: cities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0, // Ensures tiles are square
          ),
          itemBuilder: (context, index) {
            final city = cities[index];
            final cityName = city['name'] as String;
            final imagePath = city['image'] as String;

            return GestureDetector(
              onTap: () async {
                // Show loading while fetching cinemas
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: kPrimaryColor,
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

                // Pass movieId and movieTitle to CinemaListScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CinemaListScreen(
                      cityName: city['name'],
                      cinemas: cinemas,
                      movieId: movieId,
                      movieTitle: movieTitle,
                    ),
                  ),
                );
              },
              child: ClipRRect( // Clip the tile to give it rounded corners
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [ // Optional: Add shadow for depth
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. City Image
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover, // Ensures the image covers the tile area
                        // Fallback in case the image asset is missing
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Icon(Icons.location_city, size: 40, color: kPrimaryColor),
                          ),
                        ),
                      ),
                      
                      // 2. Gradient Overlay for text contrast (Bottom Fade)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      
                      // 3. City Name Text
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Text(
                          cityName,
                          style: const TextStyle(
                            color: Colors.white, // White text over the dark overlay
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),)
      ),
    );
  }
}