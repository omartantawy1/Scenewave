import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeServices {
  static final String _apiKey = '0b68be6cb8f2c0b76a7cce57286a8fe2';
  static final String _baseUrl = 'https://api.themoviedb.org/3';

  static Future<List<Map<String, dynamic>>> fetchNowPlaying() async {
    final url = '$_baseUrl/movie/now_playing?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  static Future<List<Map<String, dynamic>>> fetchPopular() async {
    final url = '$_baseUrl/movie/popular?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  static Future<List<Map<String, dynamic>>> fetchTrending() async {
    final url = '$_baseUrl/trending/movie/day?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  static Future<List<Map<String, dynamic>>> fetchUpcoming() async {
    final url = '$_baseUrl/movie/upcoming?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  static Future<List<Map<String, dynamic>>> _fetchMovies(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
        data['results'].map(
          (movie) => {
            'title': movie['title'] ?? 'Unknown',
            'image':
                movie['poster_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                    : null,
            'id': movie['id'],
            'release_date': movie['release_date'] ?? '',
            'vote_average': movie['vote_average']?.toString() ?? 'N/A',
            'language': movie['original_language']?.toUpperCase() ?? 'N/A',
          },
        ),
      );
    } else {
      return [];
    }
  }
}
