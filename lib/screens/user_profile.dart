import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movies_app/screens/movie_details.dart';
import 'package:movies_app/services/user_profile_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  User? user;
  bool isFavouriteSelected = true;

  late Stream<List<Map<String, dynamic>>> favMoviesStream;
  late Stream<List<Map<String, dynamic>>> watchLaterStream;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    if (user != null) {
      favMoviesStream = UserProfileService.favoriteMoviesStream(user!.email!);
      watchLaterStream = UserProfileService.watchLaterMoviesStream(
        user!.email!,
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? _buildGuestScreen(context)
        : _buildUserProfile(context);
  }

  Widget _buildUserProfile(BuildContext context) {
    final String userEmail = user?.email ?? "Guest";

    return Scaffold(
      backgroundColor: Color(0xff1D1D28),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: _signOut,
        child: Icon(Icons.logout, color: Colors.white),
        tooltip: 'Logout',
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 70),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/smile1.jpg'),
            ),
            SizedBox(height: 10),
            Text(
              userEmail,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconButton(
                  title: "Favourites",
                  icon: Icons.favorite,
                  isSelected: isFavouriteSelected,
                  onTap: () {
                    setState(() {
                      isFavouriteSelected = true;
                    });
                  },
                ),
                _iconButton(
                  title: "Watch Later",
                  icon: Icons.watch_later,
                  isSelected: !isFavouriteSelected,
                  onTap: () {
                    setState(() {
                      isFavouriteSelected = false;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child:
                    isFavouriteSelected
                        ? _buildMovieGrid(favMoviesStream)
                        : _buildMovieGrid(watchLaterStream),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieGrid(Stream<List<Map<String, dynamic>>> movieStream) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: movieStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No movies to show.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final movies = snapshot.data!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 24) / 3;
            final itemHeight =
                itemWidth * 1.5; // reduced to allow space for text

            return GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 15,
              childAspectRatio:
                  itemWidth / (itemHeight + 35), // give room for title
              children:
                  movies.map((movie) {
                    final imageUrl =
                        movie['poster'] ?? movie['image_url'] ?? '';
                    final movieId = movie['movieId'] ?? movie['movie_id'];
                    final movieName =
                        movie['title'] ?? movie['movie_name'] ?? 'Unknown';

                    return GestureDetector(
                      onTap: () {
                        if (movieId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MovieDetails(movieId: movieId),
                            ),
                          );
                        }
                      },
                      child: SizedBox(
                        width: itemWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  imageUrl.isNotEmpty
                                      ? Image.network(
                                        'https://image.tmdb.org/t/p/w300$imageUrl',
                                        fit: BoxFit.cover,
                                        width: itemWidth,
                                        height: itemHeight,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: itemHeight,
                                                  width: itemWidth,
                                                  color: Colors.grey[800],
                                                  child: Icon(
                                                    Icons.movie,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      )
                                      : Container(
                                        height: itemHeight,
                                        width: itemWidth,
                                        color: Colors.grey[800],
                                        child: Icon(
                                          Icons.movie,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: Text(
                                movieName,
                                maxLines: 1,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildGuestScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1D1D28),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          margin: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/questions-rafiki.png',
                  width: 220,
                  height: 220,
                ),
                SizedBox(height: 20),
                Text(
                  "You're not a user yet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                const Text(
                  "Sign up now to enjoy personalized features!",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Register Now",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.deepOrange : Colors.white),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.deepOrange : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
