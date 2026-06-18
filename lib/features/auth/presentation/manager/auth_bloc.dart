import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC that manages authentication state using FirebaseAuth.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthBloc({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<LoginRequested>(_onLogin);
    on<SignUpRequested>(_onSignUp);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<LogoutRequested>(_onLogout);
    on<PasswordResetRequested>(_onPasswordReset);
  }

  /// Check if user is already authenticated on app start.
  Future<void> _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthSuccess(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle email/password login.
  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signInWithEmail(event.email, event.password);
      emit(AuthSuccess(user: credential.user!));
    } on AuthCancelledException catch (e) {
      emit(AuthFailure(message: e.message));
    } on FirebaseException catch (e) {
      emit(AuthFailure(message: _mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle new account creation.
  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signUpWithEmail(
        event.email,
        event.password,
        displayName: event.name,
      );

      // Create initial user document in Firestore
      await _firestoreService.saveUserPreferences(
        uid: credential.user!.uid,
        categories: [],
        languages: ['English'],
        hasCompletedOnboarding: false,
      );

      emit(AuthSuccess(user: credential.user!));
    } on FirebaseException catch (e) {
      emit(AuthFailure(message: _mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle Google Sign-In.
  Future<void> _onGoogleSignIn(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user!;

      // Check if this is a new user and create Firestore doc
      final prefs = await _firestoreService.getUserPreferences(user.uid);
      if (prefs == null) {
        await _firestoreService.saveUserPreferences(
          uid: user.uid,
          categories: [],
          languages: ['English'],
          hasCompletedOnboarding: false,
        );
      }

      emit(AuthSuccess(user: user));
    } on AuthCancelledException catch (e) {
      emit(AuthFailure(message: e.message));
    } on FirebaseException catch (e) {
      emit(AuthFailure(message: _mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Handle sign out.
  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    emit(const AuthUnauthenticated());
  }

  /// Handle password reset.
  Future<void> _onPasswordReset(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.resetPassword(event.email);
      emit(const PasswordResetSent());
    } on FirebaseException catch (e) {
      emit(AuthFailure(message: _mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Maps Firebase error codes to user-friendly messages.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'Authentication error: $code';
    }
  }
}
