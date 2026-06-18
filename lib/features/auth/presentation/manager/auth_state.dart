import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth operation in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user.uid];
}

/// Auth operation failed.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// User is not authenticated (logged out or no session).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Password reset email sent successfully.
class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}
