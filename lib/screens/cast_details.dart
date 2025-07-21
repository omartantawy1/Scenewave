import 'package:flutter/material.dart';
import 'package:movies_app/screens/movie_details.dart';
import 'package:movies_app/services/cast_services.dart';

class CastDetails extends StatefulWidget {
  const CastDetails({super.key});

  @override
  State<CastDetails> createState() => _CastDetailsState();
}

class _CastDetailsState extends State<CastDetails> {
  Map<String, dynamic>? personData;
  List<dynamic> filmography = [];
  bool isLoading = true;
  bool showFullBio = false;
  late int personId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    personId = ModalRoute.of(context)!.settings.arguments as int;
    fetchPersonData(personId);
  }

  Future<void> fetchPersonData(int id) async {
    final person = await CastServices.fetchPersonDetails(id);
    final movies = await CastServices.fetchFilmography(id);

    setState(() {
      personData = person;
      filmography = movies;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1D1D28),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : personData == null
              ? const Center(
                child: Text(
                  "Failed to load data",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Hero(
                          tag: 'castImage-$personId',
                          child:
                              personData!['profile_path'] != null
                                  ? Image.network(
                                    'https://image.tmdb.org/t/p/w500${personData!['profile_path']}',
                                    width: double.infinity,
                                    height: 450,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'images/loading.png',
                                    width: double.infinity,
                                    height: 450,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xff1D1D28),
                                Color(0xff1D1D28),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                personData!['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Date of birth:  ${personData!['birthday'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biography:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            personData!['biography'] ??
                                'No biography available.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                            maxLines: showFullBio ? null : 5,
                            overflow:
                                showFullBio
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showFullBio = !showFullBio;
                              });
                            },
                            child: Text(
                              showFullBio ? 'Read less' : 'Read more',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Filmography',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filmography.length,
                              itemBuilder: (context, index) {
                                final movie = filmography[index];
                                return _buildMovieCard(
                                  movie['title'] ?? movie['name'] ?? '',
                                  movie['character'] ?? '',
                                  movie['poster_path'],
                                  movie['id'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildMovieCard(
    String title,
    String role,
    String? imagePath,
    int movieId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetails(movieId: movieId)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  imagePath != null
                      ? Image.network(
                        'https://image.tmdb.org/t/p/w185$imagePath',
                        width: 100,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.white,
                            ),
                      )
                      : Image.asset(
                        'images/loading.png',
                        width: 100,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 100,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                role,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
