import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';

class ApiService {
  final String apiKey = "4bba6688b6ccd7f19cb0988863f028dc"; // Replace with your TMDB key
  final String baseUrl = "https://api.themoviedb.org/3";

  Future<List<Movie>> fetchNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse("$baseUrl/movie/now_playing?api_key=$apiKey&language=en-US&page=1&include_adult=false&certification_country=US&certification.lte=PG-13"),
    );

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load movies");
    }
  }

 Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
  final response = await http.get(
    Uri.parse("$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId&sort_by=popularity.desc&page=1&include_adult=false&certification_country=US&certification.lte=PG-13"),
  );

  if (response.statusCode == 200) {
    final List results = json.decode(response.body)['results'];
    final filtered = results.where((m) => m['adult'] == false).toList();
    return filtered.map((json) => Movie.fromJson(json)).toList();
  } else {
    throw Exception("Failed to load movies by genre");
  }
}

Future<List<Movie>> fetchUpcomingMovies() async {
  final response = await http.get(Uri.parse(
    "https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey&language=en-US&page=1&include_adult=false&certification_country=US&certification.lte=PG-13",
  ));

  if (response.statusCode == 200) {
    final List results = json.decode(response.body)['results'];
    return results.map((json) => Movie.fromJson(json)).toList();
  } else {
    throw Exception("Failed to load upcoming movies");
  }
}

 Future<MovieDetail> fetchMovieDetails(int movieId) async {
  final detailResponse = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=en-US'));
  final creditsResponse = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey'));
  final reviewsResponse = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId/reviews?api_key=$apiKey'));

  if (detailResponse.statusCode == 200 &&
      creditsResponse.statusCode == 200 &&
      reviewsResponse.statusCode == 200) {
    final detailJson = jsonDecode(detailResponse.body);
    final creditsJson = jsonDecode(creditsResponse.body);
    final reviewsJson = jsonDecode(reviewsResponse.body);

    return MovieDetail(
      id: detailJson['id'],
      title: detailJson['title'] ?? '',
      overview: detailJson['overview'] ?? '',
      releaseDate: detailJson['release_date'] ?? '',
      language: detailJson['original_language'] ?? '',
      runtime: detailJson['runtime'] ?? 0,
      rating: (detailJson['vote_average'] ?? 0).toDouble(),
      voteCount: detailJson['vote_count'] ?? 0,
      backdropPath: detailJson['backdrop_path'] ?? '',
      posterPath: detailJson['poster_path'] ?? '',
      cast: (creditsJson['cast'] as List)
          .map((c) => Cast.fromJson(c))
          .toList(),
      reviews: (reviewsJson['results'] as List)
          .map((r) => Review.fromJson(r))
          .toList(),
    );
  } else {
    throw Exception('Failed to fetch movie details');
  }
 }}