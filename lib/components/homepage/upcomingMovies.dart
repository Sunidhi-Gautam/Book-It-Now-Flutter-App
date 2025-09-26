import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api_services/tmdb_api.dart';
import '../../models/constants.dart';
import '../../models/movie_model.dart';

class UpcomingMovies extends StatefulWidget {
  const UpcomingMovies({super.key});

  @override
  State<UpcomingMovies> createState() => _UpcomingMoviesState();
}

class _UpcomingMoviesState extends State<UpcomingMovies> {
  late Future<List<Movie>> upcomingMovies;

  @override
  void initState() {
    super.initState();
    upcomingMovies = ApiService().fetchUpcomingMovies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320, // slightly taller for long names
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upcoming Movies 🎞️",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: secondaryFonts,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: upcomingMovies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: LoadingAnimationWidget.waveDots(
              color: const Color.fromARGB(158, 255, 255, 255),
              size: 50, // Adjust size if needed
            ),);
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No upcoming movies found"));
                  }

                  final movies = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 20), // bottom padding
                    itemCount: movies.length,
                    itemBuilder: (_, index) {
                      final movie = movies[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                height: 170,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 120,
                              child: Text(
                                movie.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: secondaryFonts,
                                  color: Colors.white 
                                                               ),
                                softWrap: true,
                                maxLines: 2, // limits to 2 lines
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
