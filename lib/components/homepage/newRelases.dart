import 'package:bookmyshowclone/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api_services/tmdb_api.dart';
import '../../models/movie_model.dart';
import '../../screens/new_releases_screen.dart';
import '../../screens/movie_detail_screen.dart'; //movie detail screen fetch krne k liye

class NewReleases extends StatefulWidget {
  const NewReleases({super.key});

  @override
  State<NewReleases> createState() => _NewReleasesState();
}

class _NewReleasesState extends State<NewReleases> {
  late Future<List<Movie>> futureMovies;

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService().fetchNowPlayingMovies();
  }

  @override
  Widget build(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;

    return SizedBox(
      width: widthSize,
      height: 320,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
               Text("New Releases ✨",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: secondaryFonts, color: Colors.white)),
                const Spacer(),
                TextButton(
                   onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewReleasesScreen()),
    );
  },
  child: Text("View All", style: TextStyle(color: const Color.fromARGB(255, 241, 185, 181), fontSize: 15, fontFamily: subtitleFonts), ),
),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: futureMovies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: LoadingAnimationWidget.waveDots(
              color: const Color.fromARGB(158, 255, 255, 255),
              size: 50, // Adjust size if needed
            ),);
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No movies found"));
                  }

                  final movies = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length,
                    itemBuilder: (_, index) {
                      final movie = movies[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //------------new code for on tap to movie detail screen----------------
                              // // Poster
                              // ClipRRect(
                              //   borderRadius: BorderRadius.circular(10),
                              //   child: Image.network(
                              //     "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                              //     height: 180,
                              //     width: 150,
                              //     fit: BoxFit.cover,
                              //   ),
                              // ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // Pass the ID and title, not the whole object
                                      builder: (context) => MovieDetailScreen(
                                        movieId: movie.id, // Assuming your model has 'id'
                                        movieTitle: movie.title,
                                      ),
                                      // --------------------------
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                    height: 180,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),


                              //------------new code for on tap to movie detail screen----------------
                              const SizedBox(height: 5),
                              // Title
                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: secondaryFonts,
                                  color: Colors.white
                                ),
                              ),
                              const SizedBox(height: 3),
                              // Rating
                              Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: movie.rating / 2,
                                    itemBuilder: (_, __) => const Icon(
                                        Icons.star, color: Colors.amber),
                                    itemSize: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    movie.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
