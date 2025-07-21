import 'dart:convert';
import 'package:http/http.dart' as http;

class CastServices {
  static const String _apiKey = '0b68be6cb8f2c0b76a7cce57286a8fe2';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  /// Fetch biography, profile image, birthday, etc.
  static Future<Map<String, dynamic>?> fetchPersonDetails(int personId) async {
    final url = '$_baseUrl/person/$personId?api_key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load person details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching person details: $e');
      return null;
    }
  }

  /// Fetch movie credits (filmography)
  static Future<List<dynamic>> fetchFilmography(int personId) async {
    final url = '$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['cast']; // List of movies with role and poster
      } else {
        print('Failed to load filmography: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching filmography: $e');
      return [];
    }
  }
}
