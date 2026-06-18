import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/detail/presentation/pages/detail_page.dart';
import '../../features/home/domain/entities/story.dart';

/// Named route constants and route generator for the app.
class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String signup = '/signup';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashPage(), settings);
      case login:
        return _buildRoute(const LoginPage(), settings);
      case signup:
        return _buildRoute(const SignUpPage(), settings);
      case onboarding:
        return _buildRoute(const OnboardingPage(), settings);
      case home:
        return _buildRoute(const HomePage(), settings);
      case detail:
        final story = settings.arguments as Story;
        return _buildRoute(DetailPage(story: story), settings);
      default:
        return _buildRoute(const SplashPage(), settings);
    }
  }

  /// Builds a page route with a smooth fade + slide transition.
  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
