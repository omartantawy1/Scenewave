import 'dart:convert';
import 'package:http/http.dart' as http;

class GenreSelectionServices {
  static const String _apiKey = '0b68be6cb8f2c0b76a7cce57286a8fe2';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // ✅ Get list of genre names
  static Future<List<String>> getGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> genres = data['genres'];
      return genres.map<String>((genre) => genre['name'] as String).toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }

  // ✅ Get genre name -> ID mapping
  static Future<Map<String, int>> getGenreMap() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> genres = data['genres'];
      return {
        for (var genre in genres) genre['name'] as String: genre['id'] as int,
      };
    } else {
      throw Exception('Failed to load genre map');
    }
  }

  // ✅ Get list of filtered movies
  static Future<Map<String, dynamic>> getFilteredMovies({
    String? year,
    double? minRating,
    List<String>? genreNames,
    String? language,
    String sortBy = 'popularity.desc',
    int page = 1,
  }) async {
    final genreMap = await getGenreMap();
    final List<int> genreIds =
        genreNames?.map((name) => genreMap[name]).whereType<int>().toList() ??
        [];

    final Map<String, String> queryParameters = {
      'api_key': _apiKey,
      'language': 'en-US',
      'sort_by': sortBy,
      'page': page.toString(),
    };

    // ✅ Add rating filter
    if (minRating != null) {
      queryParameters['vote_average.gte'] = minRating.toString();
    }

    // ✅ Add genre filter
    if (genreIds.isNotEmpty) {
      queryParameters['with_genres'] = genreIds.join(',');
    }

    // ✅ Add language filter
    if (language != null && language.isNotEmpty) {
      queryParameters['with_original_language'] = language;
    }

    // ✅ Add year filter (supports range and single year)
    if (year != null && year.isNotEmpty) {
      if (year.contains('-')) {
        final parts = year.split('-');
        if (parts.length == 2) {
          final fromYear = parts[0];
          final toYear = parts[1];
          queryParameters['primary_release_date.gte'] = '$fromYear-01-01';
          queryParameters['primary_release_date.lte'] = '$toYear-12-31';
        }
      } else {
        queryParameters['primary_release_year'] = year;
      }
    }

    final uri = Uri.parse(
      '$_baseUrl/discover/movie',
    ).replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'results': data['results'],
        'total_pages': data['total_pages'] ?? 1,
      };
    } else {
      throw Exception('Failed to load filtered movies');
    }
  }

  // ✅ Optional: Get total movie count for filters
  static Future<int> getFilteredMoviesCount({
    String? year,
    double? minRating,
    List<String>? genreNames,
    String? language,
    String sortBy = 'popularity.desc',
  }) async {
    final genreMap = await getGenreMap();
    final List<int> genreIds =
        genreNames?.map((name) => genreMap[name]).whereType<int>().toList() ??
        [];

    final Map<String, String> queryParameters = {
      'api_key': _apiKey,
      'language': 'en-US',
      'sort_by': sortBy,
      'page': '1',
    };

    if (minRating != null) {
      queryParameters['vote_average.gte'] = minRating.toString();
    }

    if (genreIds.isNotEmpty) {
      queryParameters['with_genres'] = genreIds.join(',');
    }

    if (language != null && language.isNotEmpty) {
      queryParameters['with_original_language'] = language;
    }

    if (year != null && year.isNotEmpty) {
      if (year.contains('-')) {
        final parts = year.split('-');
        if (parts.length == 2) {
          final fromYear = parts[0];
          final toYear = parts[1];
          queryParameters['primary_release_date.gte'] = '$fromYear-01-01';
          queryParameters['primary_release_date.lte'] = '$toYear-12-31';
        }
      } else {
        queryParameters['primary_release_year'] = year;
      }
    }

    final uri = Uri.parse(
      '$_baseUrl/discover/movie',
    ).replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['total_results'] ?? 0;
    } else {
      throw Exception('Failed to load filtered movie count');
    }
  }
}
