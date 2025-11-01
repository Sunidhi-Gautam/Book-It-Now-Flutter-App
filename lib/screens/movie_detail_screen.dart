import 'package:bookmyshowclone/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../api_services/tmdb_api.dart';
import '../models/movie_detail_model.dart';
import 'select_location_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;
  final String movieTitle;
  const MovieDetailScreen(
      {super.key, required this.movieId, required this.movieTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      appBar: AppBar(
        title: Text(
          "Movie Details",
          style: TextStyle(
              fontFamily: secondaryFonts,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // --- Bottom Proceed Button ---
      bottomNavigationBar: FutureBuilder<MovieDetail>(
        future: ApiService().fetchMovieDetails(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 40,
              child: Center(
                  child: CircularProgressIndicator(
                color: Color.fromARGB(255, 15, 14, 14),
              )),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox(height: 50);
          }

          final movie = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final castList = movie.cast.map((actor) => actor.name).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectLocationScreen(
                      movieId: movieId,
                      movieTitle: movie.title,
                      castList: castList,
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

      // --- Main Body ---
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
                // --- Movie Banner ---
                Image.network(
                  "https://image.tmdb.org/t/p/w500${movie.backdropPath}",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // --- Title ---
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),

                // --- Rating ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(
                        "${movie.rating.toStringAsFixed(1)} / 10 (${movie.voteCount} votes)",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- Overview ---
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    movie.overview,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                // --- Cast Section ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "Cast",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
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

                // --- TMDB Reviews (existing) ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "Reviews",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                if (movie.reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: movie.reviews.length,
                    itemBuilder: (_, index) {
                      final review = movie.reviews[index];
                      return Card(
                        color: const Color.fromARGB(255, 30, 29, 29),
                        shadowColor: const Color.fromARGB(255, 247, 245, 245),
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
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                review.content,
                                // maxLines: 6,
                                // overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 6),

                // --- Firebase User Reviews (show username + comments) ---
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .where('movieId', isEqualTo: movie.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      // if no firebase reviews, nothing more to show
                      return const SizedBox.shrink();
                    }

                    final firebaseDocs = snapshot.data!.docs;

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: firebaseDocs.length,
                      itemBuilder: (context, index) {
                        final reviewData =
                            firebaseDocs[index].data() as Map<String, dynamic>;
                        final userId = reviewData['userId'] as String?;
                        final comment =
                            (reviewData['comments'] ?? '').toString();

                        // fetch username from /users/{userId}
                        return FutureBuilder<DocumentSnapshot>(
                          future: (userId != null && userId.isNotEmpty)
                              ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .get()
                              // ignore: null_argument_to_non_null_type
                              : Future.value(null),
                          builder: (context, userSnapshot) {
                            String username = 'Anonymous';
                            if (userSnapshot.hasData &&
                                userSnapshot.data != null &&
                                userSnapshot.data!.exists) {
                              final userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                              if (userData != null) {
                                username = (userData['username'] ??
                                        userData['username'] ??
                                        'Anonymous')
                                    .toString();
                              }
                            }

                            return _ExpandableCommentCard(
                              username: username,
                              comment: comment,
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Firebase user review card — matches TMDB review UI
class _ExpandableCommentCard extends StatelessWidget {
  final String username;
  final String comment;

  const _ExpandableCommentCard({
    // ignore: unused_element_parameter
    super.key,
    required this.username,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 30, 29, 29),
      shadowColor: const Color.fromARGB(255, 247, 245, 245),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username like TMDB Author
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),

            // Full comment text — no truncation
            Text(
              comment.isNotEmpty ? comment : "(No comment)",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
