import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchServices {
  static const String _apiKey = '0b68be6cb8f2c0b76a7cce57286a8fe2';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // 🔍 Search for movies
  static Future<List<dynamic>> searchMovies(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&query=$query',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['results'];
    } else {
      return [];
    }
  }

  // 🔍 Search for actors
  static Future<List<dynamic>> searchActors(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search/person?api_key=$_apiKey&query=$query',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['results'];
    } else {
      return [];
    }
  }

  // 📥 Fetch genre list dynamically
  static Future<Map<int, String>> fetchGenres() async {
    final url = Uri.parse(
      '$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List genres = decoded['genres'];

      return {
        for (var genre in genres) genre['id'] as int: genre['name'] as String,
      };
    } else {
      return {};
    }
  }

  // 🎂 Fetch actor age
  static Future<int?> fetchActorAge(int personId) async {
    final url = Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final birthDate = data['birthday'];
      if (birthDate != null && birthDate.isNotEmpty) {
        final birth = DateTime.parse(birthDate);
        final now = DateTime.now();
        return now.year -
            birth.year -
            ((now.month < birth.month ||
                    (now.month == birth.month && now.day < birth.day))
                ? 1
                : 0);
      }
    }
    return null;
  }
}
