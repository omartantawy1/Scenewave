import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  static final _firestore = FirebaseFirestore.instance;

  // ------------------ FAVORITES ------------------
  static Stream<List<Map<String, dynamic>>> favoriteMoviesStream(String email) {
    return _firestore
        .collection('users')
        .doc(email)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Future<void> addFavorite({
    required String email,
    required int movieId,
    required String movieName,
    required String imageUrl,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .collection('favorites')
        .doc(movieId.toString());

    await docRef.set({
      'movie_id': movieId,
      'movie_name': movieName,
      'image_url': imageUrl,
    });
  }

  static Future<void> removeFavorite(String email, int movieId) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .collection('favorites')
        .doc(movieId.toString());

    await docRef.delete();
  }

  static Future<bool> checkIfFavorite(String email, int movieId) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .collection('favorites')
        .doc(movieId.toString());

    final doc = await docRef.get();
    return doc.exists;
  }

  static Future<List<String>> fetchFavoritePosters(String email) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(email)
            .collection('favorites')
            .get();

    return snapshot.docs
        .map((doc) => doc.data()['image_url'] as String)
        .where((url) => url.isNotEmpty)
        .toList();
  }

  // ------------------ WATCH LATER ------------------
  static Stream<List<Map<String, dynamic>>> watchLaterStream(String email) {
    return _firestore
        .collection('users')
        .doc(email)
        .collection('watch_later')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<Map<String, dynamic>>> watchLaterMoviesStream(
    String email,
  ) {
    return _firestore
        .collection('users')
        .doc(email)
        .collection('watch_later')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList(),
        );
  }

  static Future<void> addToWatchLater({
    required String email,
    required int movieId,
    required String movieName,
    required String imageUrl,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .collection('watch_later')
        .doc(movieId.toString());

    await docRef.set({
      'movie_id': movieId,
      'movie_name': movieName,
      'image_url': imageUrl,
    });
  }

  static Future<void> removeFromWatchLater(String email, int movieId) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .collection('watch_later')
        .doc(movieId.toString());

    await docRef.delete();
  }

  static Future<bool> checkIfInWatchLater(String email, int movieId) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .collection('watch_later')
        .doc(movieId.toString());

    final doc = await docRef.get();
    return doc.exists;
  }

  static Future<List<String>> fetchWatchLaterPosters(String email) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(email)
            .collection('watch_later')
            .get();

    return snapshot.docs
        .map((doc) => doc.data()['image_url'] as String)
        .where((url) => url.isNotEmpty)
        .toList();
  }
}
