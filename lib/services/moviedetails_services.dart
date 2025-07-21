import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieDetailsServices {
  static final String _apiKey = '0b68be6cb8f2c0b76a7cce57286a8fe2';
  static final String _baseUrl = 'https://api.themoviedb.org/3';

  static Future<Map<String, dynamic>?> fetchMovieDetails(int movieId) async {
    final url = '$_baseUrl/movie/$movieId?api_key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching movie details: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMovieCast(int movieId) async {
    final url = '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cast = data['cast'] as List;

        return cast.take(10).map<Map<String, dynamic>>((actor) {
          return {
            'id': actor['id'],
            'name': actor['name'],
            'profile_path': actor['profile_path'],
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching movie cast: $e');
      return [];
    }
  }

  static Future<String?> fetchTrailerKey(int movieId) async {
    final url = '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        final trailer = results.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );

        return trailer != null ? trailer['key'] : null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching trailer key: $e');
      return null;
    }
  }
}
