import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Central authentication service wrapping FirebaseAuth.
/// Handles Email/Password login, Google Sign-In, and sign-out.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Current authenticated user (null if not logged in).
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes for reactive listening.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create a new account with email and password.
  Future<UserCredential> signUpWithEmail(String email, String password, {String? displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Set display name if provided
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }

    return credential;
  }

  /// Sign in with Google.
  Future<UserCredential> signInWithGoogle() async {
    // Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw AuthCancelledException(
        code: 'sign-in-cancelled',
        message: 'Google Sign-In was cancelled by the user.',
      );
    }

    // Obtain auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out from all providers.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

/// Custom exception for auth-specific errors.
class AuthCancelledException implements Exception {
  final String code;
  final String message;

  AuthCancelledException({required this.code, required this.message});

  @override
  String toString() => message;
}
