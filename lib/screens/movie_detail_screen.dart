import 'package:bookmyshowclone/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../api_services/tmdb_api.dart';
import '../models/movie_detail_model.dart';
import 'select_location_screen.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movie Details")),
      
      // Bottom Buy Ticket button
      bottomNavigationBar: FutureBuilder<MovieDetail>(
        future: ApiService().fetchMovieDetails(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(color: Colors.white,)),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox(height: 50);
          }

          final movie = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectLocationScreen(
                      movieId: movieId,
                      movieTitle: movie.title,
                    ),
                  ),
                );
              },
              child: const Text(
                "Proceed",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          );
        },
      ),

      // Movie Detail Body
      body: FutureBuilder<MovieDetail>(
        future: ApiService().fetchMovieDetails(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.waveDots(
                color: const Color.fromARGB(158, 93, 18, 18),
                size: 50,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final movie = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Banner
                Image.network(
                  "https://image.tmdb.org/t/p/w500${movie.backdropPath}",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Rating
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(
                        "${movie.rating.toStringAsFixed(1)} / 10 (${movie.voteCount} votes)",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Overview
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    movie.overview,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Cast Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "Cast",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movie.cast.length,
                    itemBuilder: (_, index) {
                      final actor = movie.cast[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                actor.profilePath.isNotEmpty
                                    ? "https://image.tmdb.org/t/p/w200${actor.profilePath}"
                                    : "https://via.placeholder.com/100",
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              actor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              actor.character,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Reviews Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "Reviews",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (movie.reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text("No reviews yet."),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(), // To allow inside scroll view
                    shrinkWrap: true,
                    itemCount: movie.reviews.length,
                    itemBuilder: (_, index) {
                      final review = movie.reviews[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                review.content,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
