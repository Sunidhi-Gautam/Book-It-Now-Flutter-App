class Movie {
  final String title;
  final String posterPath;
  final String backdropPath;
  final double rating;
  final String overview;

  Movie({
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.overview,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? '',
      posterPath: "https://image.tmdb.org/t/p/w500${json['poster_path']}",
      backdropPath: "https://image.tmdb.org/t/p/w500${json['backdrop_path']}",
      rating: (json['vote_average'] ?? 0).toDouble(),
      overview: json['overview'] ?? '',
    );
  }
}
