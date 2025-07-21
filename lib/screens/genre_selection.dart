import 'package:flutter/material.dart';
import '../services/genre_selection_services.dart';

class GenreSelection extends StatefulWidget {
  final String filterType; // 'year', 'genre', or 'language'

  const GenreSelection({super.key, required this.filterType});

  @override
  State<GenreSelection> createState() => _GenreSelectionState();
}

class _GenreSelectionState extends State<GenreSelection> {
  final List<String> years = [
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020-Now',
    '2010-2019',
    '2000-2009',
    '1990-1999',
    '1980-1989',
    '1970-1979',
    '1950-1969',
    '1900-1950',
  ];

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'Spanish', 'code': 'es'},
    {'name': 'Arabic', 'code': 'ar'},
    {'name': 'Japanese', 'code': 'ja'},
    {'name': 'Korean', 'code': 'ko'},
    {'name': 'German', 'code': 'de'},
    {'name': 'Mandarin', 'code': 'zh'},
    {'name': 'Italian', 'code': 'it'},
  ];

  List<String> genres = [];
  Set<String> selectedGenres = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.filterType == 'genre') {
      loadGenres();
    } else {
      isLoading = false;
    }
  }

  void loadGenres() async {
    try {
      final data = await GenreSelectionServices.getGenres();
      setState(() {
        genres = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading genres: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGenre = widget.filterType == 'genre';
    final isYear = widget.filterType == 'year';
    final isLanguage = widget.filterType == 'language';

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xff1D1D28),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    final items =
        isGenre
            ? genres
            : isYear
            ? years
            : languages.map((lang) => lang['code']!).toList();

    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      appBar: AppBar(
        title: Text(
          isGenre
              ? 'Select Genres'
              : isYear
              ? 'Select Year'
              : 'Select Language',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff1D1D28),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final value = items[index];

              // Year or Language - Single Selection
              if (!isGenre) {
                return ListTile(
                  title: Text(
                    isLanguage
                        ? languages.firstWhere(
                          (lang) => lang['code'] == value,
                        )['name']!
                        : value,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, value),
                );
              }

              // Genre - Multi Selection
              final isSelected = selectedGenres.contains(value);
              return ListTile(
                title: Text(
                  value,
                  style: TextStyle(
                    color: isSelected ? Colors.red : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.red)
                        : null,
                onTap: () {
                  setState(() {
                    isSelected
                        ? selectedGenres.remove(value)
                        : selectedGenres.add(value);
                  });
                },
              );
            },
          ),
          if (isGenre && selectedGenres.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, selectedGenres.toList());
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
