import 'package:flutter/material.dart';
import '../../../models/constants.dart';
import '../../screens/genre_movies_scree.dart';

class BrowseByGenre extends StatelessWidget {
  const BrowseByGenre({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            "Browse by Genre 🔍",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: secondaryFonts,
              color: darkColor,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal list of genres inside decorated container
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenreMoviesScreen(
                          genreId: genre['id'],
                          genreName: genre['name'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color.fromARGB(233, 74, 4, 4)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 0.2
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        genre['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
