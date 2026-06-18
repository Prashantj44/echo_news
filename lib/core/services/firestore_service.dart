import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/home/domain/entities/story.dart';

/// Firestore service for persisting user preferences and bookmarks.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User Preferences ──

  /// Save user preferences (categories, languages, country, onboarding status).
  Future<void> saveUserPreferences({
    required String uid,
    required List<String> categories,
    required List<String> languages,
    String country = 'us',
    String apiKey = '',
    bool hasCompletedOnboarding = true,
  }) async {
    await _db.collection('users').doc(uid).set({
      'categories': categories,
      'languages': languages,
      'country': country,
      'apiKey': apiKey,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user preferences.
  Future<Map<String, dynamic>?> getUserPreferences(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── Bookmarks ──

  /// Add a story to user's bookmarks.
  Future<void> addBookmark(String uid, Story story) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(story.id.toString())
        .set({
      'id': story.id,
      'title': story.title,
      'by': story.by,
      'url': story.url,
      'score': story.score,
      'time': story.time,
      'descendants': story.descendants,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a story from user's bookmarks.
  Future<void> removeBookmark(String uid, int storyId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(storyId.toString())
        .delete();
  }

  /// Check if a story is bookmarked.
  Future<bool> isBookmarked(String uid, int storyId) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(storyId.toString())
        .get();
    return doc.exists;
  }

  /// Get real-time stream of bookmarked stories.
  Stream<List<Map<String, dynamic>>> getBookmarksStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get all bookmarks as a one-time fetch.
  Future<List<Map<String, dynamic>>> getBookmarks(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .orderBy('savedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
