import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movies_app/services/home_services.dart';
import 'package:movies_app/screens/movie_details.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> popularMovies = [];
  List<Map<String, dynamic>> trendingMovies = [];
  List<Map<String, dynamic>> upcomingMovies = [];
  bool isLoading = true;

  late AnimationController _controller;
  late ScrollController _scrollController;
  final ScrollController _trendingController = ScrollController();
  final ScrollController _upcomingController = ScrollController();
  final ScrollController _popularController = ScrollController();
  double _topBarOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fetchMovies();

    _scrollController =
        ScrollController()..addListener(() {
          double offset = _scrollController.offset;
          double newOpacity = 1 - (offset / 100);
          if (newOpacity < 0) newOpacity = 0;
          if (newOpacity > 1) newOpacity = 1;

          setState(() {
            _topBarOpacity = newOpacity;
          });
        });
  }

  void fetchMovies() async {
    final results = await Future.wait([
      HomeServices.fetchNowPlaying(),
      HomeServices.fetchPopular(),
      HomeServices.fetchTrending(),
      HomeServices.fetchUpcoming(),
    ]);

    setState(() {
      popularMovies = results[0];
      trendingMovies = results[1];
      upcomingMovies = results[2];
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                    child: Image.asset(
                      'images/loading.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                )
                : SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _topBarOpacity,
                          child: Transform.scale(
                            scale: 0.8 + (_topBarOpacity * 0.2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Hero(
                                      tag: 'logoHero',
                                      child: Image.asset(
                                        'images/movie.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'SceneWave',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/search');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildSectionHeader(
                          title: 'Trending now',
                          subtitle: 'Hot today on SceneWave',
                          onViewAll: () {},
                        ),
                        const SizedBox(height: 12),
                        _buildHorizontalMovieList(trendingMovies, 'trending'),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          title: 'Upcoming movies',
                          subtitle: 'Coming soon to theaters',
                          onViewAll: () {},
                        ),
                        const SizedBox(height: 12),
                        _buildHorizontalMovieList(upcomingMovies, 'upcoming'),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          title: 'Popular movies',
                          subtitle: 'See all popular movies',
                          onViewAll: () {},
                        ),
                        const SizedBox(height: 12),
                        _buildHorizontalMovieList(popularMovies, 'popular'),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalMovieList(
    List<Map<String, dynamic>> movies,
    String keyName,
  ) {
    ScrollController controller;

    if (keyName == 'trending') {
      controller = _trendingController;
    } else if (keyName == 'upcoming') {
      controller = _upcomingController;
    } else {
      controller = _popularController;
    }

    return SizedBox(
      key: ValueKey(keyName),
      height: MediaQuery.of(context).size.width * 0.85,
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          setState(() {});
          return false;
        },
        child: ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final itemPositionOffset = index * 180.0;
            final difference =
                controller.hasClients
                    ? controller.offset - itemPositionOffset
                    : 0.0;
            final percent = (1 - (difference.abs() / 300)).clamp(0.85, 1.0);
            final scale = percent;
            final opacity = percent;

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: MovieCard(movie: movies[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetails(movieId: movie['id']),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
              child: Material(
                elevation: 6,
                shadowColor: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie['image'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.movie,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              movie['title'] ?? 'Unknown',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
