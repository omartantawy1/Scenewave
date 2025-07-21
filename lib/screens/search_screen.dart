import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movies_app/screens/movie_details.dart';
import '../services/search_services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  Timer? _debounce;
  Map<int, String> genreMap = {};
  Map<int, int> actorAges = {};

  @override
  void initState() {
    super.initState();
    loadGenres();
  }

  void loadGenres() async {
    final fetchedGenres = await SearchServices.fetchGenres();
    setState(() {
      genreMap = fetchedGenres;
    });
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          searchResults = [];
          isLoading = false;
        });
        return;
      }

      setState(() => isLoading = true);

      final results =
          selectedIndex == 0
              ? await SearchServices.searchMovies(query)
              : await SearchServices.searchActors(query);

      final lowerQuery = query.toLowerCase();

      final filtered =
          results.where((item) {
            final name =
                selectedIndex == 0
                    ? (item['title'] ?? '').toString().toLowerCase()
                    : (item['name'] ?? '').toString().toLowerCase();
            final imagePath =
                selectedIndex == 0 ? item['poster_path'] : item['profile_path'];

            return name.startsWith(lowerQuery) &&
                name.length > 1 &&
                imagePath != null &&
                imagePath.toString().isNotEmpty;
          }).toList();

      filtered.sort((a, b) {
        final popA = (a['popularity'] ?? 0).toDouble();
        final popB = (b['popularity'] ?? 0).toDouble();
        return popB.compareTo(popA);
      });

      setState(() {
        searchResults = filtered;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Explore movies & actors',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for Movies or Actors...',
                hintStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xff2A2A3D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _ToggleButton(
                    label: 'Movies',
                    selected: selectedIndex == 0,
                    onTap: () {
                      setState(() => selectedIndex = 0);
                      onSearchChanged(_searchController.text);
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  _ToggleButton(
                    label: 'Actors',
                    selected: selectedIndex == 1,
                    onTap: () {
                      setState(() => selectedIndex = 1);
                      onSearchChanged(_searchController.text);
                    },
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Search Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                    ? const Center(
                      child: Text(
                        'No results found.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        final title =
                            selectedIndex == 0
                                ? item['title'] ?? 'No Title'
                                : item['name'] ?? 'No Name';

                        final posterPath =
                            item['poster_path'] ?? item['profile_path'];
                        final imageUrl =
                            posterPath != null
                                ? 'https://image.tmdb.org/t/p/w500$posterPath'
                                : null;

                        // For actors only
                        final department =
                            selectedIndex == 1
                                ? item['known_for_department'] ?? 'Unknown'
                                : null;

                        final knownFor =
                            item['known_for'] as List<dynamic>? ?? [];
                        final topKnownTitles = knownFor
                            .take(3)
                            .map(
                              (media) => media['title'] ?? media['name'] ?? '',
                            )
                            .where((title) => title.isNotEmpty)
                            .join(', ');

                        if (selectedIndex == 1 &&
                            !actorAges.containsKey(item['id'])) {
                          SearchServices.fetchActorAge(item['id']).then((age) {
                            if (age != null) {
                              setState(() {
                                actorAges[item['id']] = age;
                              });
                            }
                          });
                        }

                        return GestureDetector(
                          onTap: () {
                            final id = item['id'];
                            if (selectedIndex == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetails(movieId: id),
                                ),
                              );
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/castDetails',
                                arguments: id,
                              );
                            }
                          },
                          child: Card(
                            color: const Color(0xff1D1D28),
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl!,
                                      width: 100,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),

                                        if (selectedIndex == 0 &&
                                            item['genre_ids'] != null) ...[
                                          Text(
                                            item['genre_ids']
                                                .take(3)
                                                .map((id) => genreMap[id] ?? '')
                                                .join(', '),
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              _infoChip(
                                                item['release_date'] != null &&
                                                        item['release_date']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? item['release_date']
                                                        .toString()
                                                        .substring(0, 4)
                                                    : 'N/A',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              _iconTextChip(
                                                Icons.star,
                                                (item['vote_average'] ?? 0)
                                                    .toStringAsFixed(1),
                                                Colors.yellow,
                                              ),
                                              const SizedBox(width: 8),
                                              _iconTextChip(
                                                Icons.language,
                                                (item['original_language'] ??
                                                        'N/A')
                                                    .toString()
                                                    .toUpperCase(),
                                                Colors.white,
                                              ),
                                            ],
                                          ),
                                        ] else if (selectedIndex == 1) ...[
                                          const SizedBox(height: 12),
                                          _iconTextChip(
                                            Icons.work,
                                            department!,
                                            Colors.blueAccent,
                                          ),
                                          _iconTextChip(
                                            Icons.movie,
                                            topKnownTitles.length > 40
                                                ? '${topKnownTitles.substring(0, 40)}...'
                                                : topKnownTitles,
                                            Colors.orange,
                                          ),
                                          const SizedBox(height: 8),
                                          _infoChip(
                                            '${actorAges[item['id']] ?? '...'} yrs old',
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: selected ? Colors.white24 : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _infoChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF2C2C2C),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}

Widget _iconTextChip(IconData icon, String label, Color iconColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    constraints: const BoxConstraints(maxWidth: 200), // prevents overflow
    decoration: BoxDecoration(
      color: const Color(0xFF2C2C2C),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
