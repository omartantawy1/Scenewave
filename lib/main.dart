import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movies_app/auth/sign_in.dart';
import 'package:movies_app/auth/sign_up.dart';
import 'package:movies_app/screens/cast_details.dart';
import 'package:movies_app/screens/genres.dart';
import 'package:movies_app/screens/home_screen.dart';
import 'package:movies_app/screens/movie_details.dart';
import 'package:movies_app/screens/search_screen.dart';
import 'package:movies_app/screens/splash_screen.dart';
import 'package:movies_app/screens/trailer_screen.dart';
import 'package:movies_app/screens/view_all_movies.dart';
import 'package:movies_app/widgets/bottom_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      initialRoute: '/splash',
      routes: {
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),

        '/splash': (context) => const SplashScreen(),
        '/': (context) => const BottomBar(),
        '/castDetails': (context) => const CastDetails(),
        '/trailer': (context) => const TrailerScreen(),
        '/genres': (context) => const Genres(),
        '/search': (context) => SearchScreen(),
        // Add others as needed
      },
    );
  }
}
