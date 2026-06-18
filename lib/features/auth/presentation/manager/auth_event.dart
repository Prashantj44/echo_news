import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// User requests email/password login.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// User requests new account creation.
class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// User requests Google Sign-In.
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// User requests sign out.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// User requests password reset email.
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// System checks current auth state on app launch.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
