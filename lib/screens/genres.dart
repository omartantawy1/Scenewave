import 'package:flutter/material.dart';
import '../services/genre_selection_services.dart';
import 'genre_selection.dart';
import 'view_all_movies.dart';

class Genres extends StatefulWidget {
  const Genres({super.key});

  @override
  State<Genres> createState() => _GenresState();
}

class _GenresState extends State<Genres> {
  String selectedSort = 'Recommended';
  String selectedYear = '2025';
  String selectedRating = 'Any rating';
  String selectedLanguage = 'en';
  Set<String> selectedGenres = {};
  int resultCount = 0;

  @override
  void initState() {
    super.initState();
    loadInitialGenres();
    fetchMovieCount();
  }

  void loadInitialGenres() async {
    try {
      final genres = await GenreSelectionServices.getGenres();
      setState(() {
        selectedGenres.addAll(genres.take(4));
      });
      fetchMovieCount();
    } catch (e) {
      print('Error loading genres: $e');
    }
  }

  Future<void> fetchMovieCount() async {
    double? rating;
    if (selectedRating != 'Any rating') {
      rating = double.tryParse(selectedRating[0]);
    }

    final count = await GenreSelectionServices.getFilteredMoviesCount(
      year: selectedYear,
      minRating: rating,
      genreNames: selectedGenres.toList(),
      language: selectedLanguage,
    );

    setState(() {
      resultCount = count;
    });
  }

  void clearAllFilters() {
    setState(() {
      selectedSort = 'Recommended';
      selectedYear = '2025';
      selectedRating = 'Any rating';
      selectedLanguage = 'en';
      selectedGenres.clear();
      resultCount = 0;
    });
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Future<void> _applyFilters() async {
    double? rating;
    if (selectedRating != 'Any rating') {
      rating = double.tryParse(selectedRating[0]);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ViewAllMovies(
              filterTitle: 'Filtered Movies',
              year: selectedYear,
              minRating: rating,
              genres: selectedGenres.toList(),
              language: selectedLanguage,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      appBar: AppBar(
        backgroundColor: const Color(0xff1D1D28),
        leading: const CloseButton(color: Colors.white),
        title: const Text(
          'Filters',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearAllFilters();
              fetchMovieCount();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Year',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GenreSelection(filterType: 'year'),
                    ),
                  );
                  if (result != null && result is String) {
                    setState(() => selectedYear = result);
                    fetchMovieCount();
                  }
                },
                child: AbsorbPointer(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    dropdownColor: const Color(0xff1D1D28),
                    decoration: _dropdownDecoration(),
                    iconEnabledColor: Colors.white,
                    items:
                        [selectedYear]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Genres',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected: ${selectedGenres.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const GenreSelection(filterType: 'genre'),
                        ),
                      );
                      if (result != null && result is List<String>) {
                        setState(() => selectedGenres.addAll(result));
                        fetchMovieCount();
                      }
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    selectedGenres
                        .map(
                          (genre) => Chip(
                            label: Text(genre),
                            backgroundColor: Colors.red,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onDeleted: () {
                              setState(() => selectedGenres.remove(genre));
                              fetchMovieCount();
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Language',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const GenreSelection(filterType: 'language'),
                    ),
                  );
                  if (result != null && result is String) {
                    setState(() => selectedLanguage = result);
                    fetchMovieCount();
                  }
                },
                child: AbsorbPointer(
                  child: DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    dropdownColor: const Color(0xff1D1D28),
                    decoration: _dropdownDecoration(),
                    iconEnabledColor: Colors.white,
                    items:
                        [selectedLanguage]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rating',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Column(
                children:
                    ['Any rating', '8 &', '7 &', '6 &']
                        .map(
                          (rating) => RadioListTile<String>(
                            value: rating,
                            groupValue: selectedRating,
                            onChanged: (val) {
                              setState(() => selectedRating = val!);
                              fetchMovieCount();
                            },
                            activeColor: Colors.red,
                            title: Text(
                              rating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _applyFilters,
                  child: Text(
                    'Show Results ($resultCount)',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
