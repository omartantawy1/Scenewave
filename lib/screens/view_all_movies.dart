import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/genre_selection_services.dart';
import 'movie_details.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewAllMovies extends StatefulWidget {
  final String filterTitle;
  final String? year;
  final double? minRating;
  final List<String>? genres;
  final String? language;
  final String sortBy;

  const ViewAllMovies({
    super.key,
    required this.filterTitle,
    this.year,
    this.minRating,
    this.genres,
    this.language,
    this.sortBy = 'popularity.desc',
  });

  @override
  State<ViewAllMovies> createState() => _ViewAllMoviesState();
}

class _ViewAllMoviesState extends State<ViewAllMovies> {
  List<dynamic> movies = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  final ScrollController _scrollController = ScrollController();
  bool get isYearRange => widget.year?.contains('-') ?? false;

  final List<Map<String, dynamic>> sortOptions = [
    {
      'label': 'Popularity',
      'value': 'popularity.desc',
      'icon': Icons.trending_down,
      'arrow': Icons.arrow_downward,
    },
    {
      'label': 'Popularity',
      'value': 'popularity.asc',
      'icon': Icons.trending_up,
      'arrow': Icons.arrow_upward,
    },
    {
      'label': 'Rating',
      'value': 'vote_average.desc',
      'icon': Icons.star,
      'arrow': Icons.arrow_downward,
    },
    {
      'label': 'Rating',
      'value': 'vote_average.asc',
      'icon': Icons.star_border,
      'arrow': Icons.arrow_upward,
    },
    {
      'label': 'Release Date',
      'value': 'release_date.desc',
      'icon': Icons.calendar_today,
      'arrow': Icons.arrow_downward,
    },
    {
      'label': 'Release Date',
      'value': 'release_date.asc',
      'icon': Icons.calendar_month,
      'arrow': Icons.arrow_upward,
    },
  ];

  String selectedSort = 'popularity.desc';

  @override
  void initState() {
    super.initState();
    selectedSort = widget.sortBy;
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await GenreSelectionServices.getFilteredMovies(
        page: currentPage,
        year: widget.year,
        minRating: widget.minRating,
        genreNames: widget.genres,
        sortBy: selectedSort,
        language: widget.language,
      );

      setState(() {
        movies = result['results'];
        totalPages = result['total_pages'] ?? 1;
      });
    } catch (e) {
      setState(() => errorMessage = 'Failed to load movies. Try again.');
    }

    setState(() => isLoading = false);
  }

  Future<void> _onRefresh() async {
    setState(() => currentPage = 1);
    await fetchMovies();
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtered by:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.year != null)
                        _buildFilterChip(
                          Icons.calendar_today,
                          'Year: ${widget.year!}',
                        ),
                      if (widget.language != null)
                        _buildFilterChip(
                          Icons.language,
                          'Lang: ${widget.language!}',
                        ),
                      if (widget.minRating != null)
                        _buildFilterChip(
                          Icons.star,
                          'Rating: ${widget.minRating!}+',
                        ),
                      if (widget.genres != null && widget.genres!.isNotEmpty)
                        ...widget.genres!.map(
                          (genre) => _buildFilterChip(Icons.movie, genre),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sort dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xff2C2C38),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSort,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: 26,
                          ),
                          dropdownColor: const Color(0xff2C2C38),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          isDense: true,
                          items:
                              sortOptions.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option['value'],
                                  child: Row(
                                    children: [
                                      Icon(
                                        option['icon'],
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        option['label'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        option['arrow'],
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedSort = value;
                                currentPage = 1;
                              });
                              fetchMovies();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Movie Grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child:
                      errorMessage != null
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: fetchMovies,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                          : isLoading
                          ? GridView.builder(
                            itemCount: 9,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.6,
                                ),
                            itemBuilder:
                                (context, index) => _buildShimmerItem(),
                          )
                          : movies.isEmpty
                          ? const Center(
                            child: Text(
                              'No movies found.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                          : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 60),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.6,
                                ),
                            itemCount: movies.length,
                            itemBuilder: (context, index) {
                              final movie = movies[index];
                              final movieId = movie['id'];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MovieDetails(movieId: movieId),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                                    'images/loading.png',
                                                  ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        movie['title'] ?? 'No Title',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),

              const SizedBox(height: 8),

              if (!isYearRange && movies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.first_page,
                              color: Colors.white,
                            ),
                            onPressed:
                                currentPage > 1
                                    ? () {
                                      setState(() => currentPage = 1);
                                      fetchMovies().then((_) {
                                        _scrollController.animateTo(
                                          0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      });
                                    }
                                    : null,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed:
                                currentPage > 1
                                    ? () {
                                      setState(() => currentPage--);
                                      fetchMovies().then((_) {
                                        _scrollController.animateTo(
                                          0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      });
                                    }
                                    : null,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: null,
                            child: Text(
                              '$currentPage',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (currentPage < totalPages) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() => currentPage++);
                                fetchMovies().then((_) {
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.last_page,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() => currentPage = totalPages);
                                fetchMovies().then((_) {
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              },
                            ),
                          ],
                        ],
                      ),
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

Widget _buildFilterChip(IconData icon, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFe53935), Color(0xFFd81b60)],
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    ),
  );
}
