import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movies_app/services/moviedetails_services.dart';

class MovieDetails extends StatefulWidget {
  final int movieId;

  const MovieDetails({required this.movieId, super.key});

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  Map<String, dynamic>? movieDetails;
  List<Map<String, dynamic>> cast = [];
  bool isLoading = true;
  bool isFavorite = false;
  bool isWatchLater = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadMovieDetails();
  }

  Future<void> loadMovieDetails() async {
    final data = await MovieDetailsServices.fetchMovieDetails(widget.movieId);
    final fetchedCast = await MovieDetailsServices.fetchMovieCast(
      widget.movieId,
    );

    if (data == null) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load movie details')),
        );
      }
      return;
    }

    setState(() {
      movieDetails = data;
      cast = fetchedCast;
      isLoading = false;
    });

    if (_auth.currentUser != null) {
      final userEmail = _auth.currentUser!.email!;
      final favSnapshot =
          await _firestore
              .collection('users')
              .doc(userEmail)
              .collection('favorites')
              .doc(widget.movieId.toString())
              .get();

      final watchSnapshot =
          await _firestore
              .collection('users')
              .doc(userEmail)
              .collection(
                'watch_later',
              ) // Fix: Use consistent collection name "watch_later"
              .doc(widget.movieId.toString())
              .get();

      setState(() {
        isFavorite = favSnapshot.exists;
        isWatchLater = watchSnapshot.exists;
      });
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xff2D2D3A),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(
              content,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Yes', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading || movieDetails == null) {
      return const Scaffold(
        backgroundColor: Color(0xff1D1D28),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final backdropPath =
        movieDetails!['backdrop_path'] ?? movieDetails!['poster_path'];

    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      extendBodyBehindAppBar: true, // full screen behind system bars
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Stack(
              children: [
                backdropPath != null
                    ? Image.network(
                      'https://image.tmdb.org/t/p/w500$backdropPath',
                      height: screenHeight * 0.4,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, size: 60),
                          ),
                    )
                    : const Center(child: Icon(Icons.broken_image, size: 60)),

                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).padding.top + 64,
                  right: 12,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final user = _auth.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "You're not signed in to save this to favorites.",
                                  ),
                                ),
                              );
                              return;
                            }

                            final confirm = await _showConfirmationDialog(
                              title:
                                  isFavorite
                                      ? 'Remove Favorite'
                                      : 'Add to Favorite',
                              content:
                                  isFavorite
                                      ? 'Are you sure you want to remove this from your favorites?'
                                      : 'Are you sure you want to add this to your favorites?',
                            );

                            if (confirm != true) return;

                            final docRef = _firestore
                                .collection('users')
                                .doc(user.email)
                                .collection('favorites')
                                .doc(widget.movieId.toString());

                            if (isFavorite) {
                              await docRef.delete();
                              setState(() => isFavorite = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Removed from Favorites"),
                                ),
                              );
                            } else {
                              await docRef.set({
                                'movieId': widget.movieId,
                                'title': movieDetails!['title'],
                                'poster': movieDetails!['poster_path'],
                              });
                              setState(() => isFavorite = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Added to Favorites")),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: Icon(
                            isWatchLater
                                ? Icons.watch_later
                                : Icons.watch_later_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final user = _auth.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "You're not signed in to add to watch later",
                                  ),
                                ),
                              );
                              return;
                            }

                            final confirm = await _showConfirmationDialog(
                              title:
                                  isWatchLater
                                      ? 'Remove Watch Later'
                                      : 'Add to Watch Later',
                              content:
                                  isWatchLater
                                      ? 'Are you sure you want to remove this from your Watch Later list?'
                                      : 'Are you sure you want to add this to your Watch Later list?',
                            );

                            if (confirm != true) return;

                            final docRef = _firestore
                                .collection('users')
                                .doc(user.email)
                                .collection(
                                  'watch_later',
                                ) // Fix: consistent collection name here too
                                .doc(widget.movieId.toString());

                            if (isWatchLater) {
                              await docRef.delete();
                              setState(() => isWatchLater = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Removed from Watch Later"),
                                ),
                              );
                            } else {
                              await docRef.set({
                                'movieId': widget.movieId,
                                'title': movieDetails!['title'],
                                'poster': movieDetails!['poster_path'],
                              });
                              setState(() => isWatchLater = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Added to Watch Later"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final trailerKey =
                              await MovieDetailsServices.fetchTrailerKey(
                                widget.movieId,
                              );
                          if (trailerKey != null && mounted) {
                            Navigator.pushNamed(
                              context,
                              '/trailer',
                              arguments: trailerKey,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Trailer not available"),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Play Trailer',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.36),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff1D1D28),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movieDetails!['title'] ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '${(movieDetails!['vote_average'] as num).toStringAsFixed(1)}/10 IMDb',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          (movieDetails!['genres'] as List)
                              .map((genre) => _buildGenreChip(genre['name']))
                              .toList(),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildDetailColumn(
                          Icons.access_time,
                          'Length',
                          '${movieDetails!['runtime']} min',
                        ),
                        SizedBox(width: 24),
                        _buildDetailColumn(
                          Icons.language,
                          'Language',
                          (movieDetails!['original_language'] as String)
                              .toUpperCase(),
                        ),
                        SizedBox(width: 24),
                        _buildDetailColumn(
                          Icons.calendar_today,
                          'Year',
                          movieDetails!['release_date']?.toString().split(
                                '-',
                              )[0] ??
                              'N/A',
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      movieDetails!['overview'] ?? '',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Cast',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cast.length,
                        itemBuilder: (context, index) {
                          final actor = cast[index];
                          return _buildCastCard(
                            actor['id'],
                            actor['name'],
                            actor['profile_path'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildGenreChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: Colors.grey[700],
    );
  }

  Widget _buildDetailColumn(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26, color: Colors.white),
        SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCastCard(int actorId, String name, String? imagePath) {
    return GestureDetector(
      onTap:
          () =>
              Navigator.pushNamed(context, '/castDetails', arguments: actorId),
      child: Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: Column(
          children: [
            Hero(
              tag: 'castImage-$actorId',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    imagePath != null
                        ? Image.network(
                          'https://image.tmdb.org/t/p/w185$imagePath',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              ),
                        )
                        : const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 80,
              child: Text(
                name,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
