import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

/// Premium animated splash screen with logo reveal and tagline.
/// Checks Firebase auth state and navigates accordingly.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _orbController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Orb floating animation
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Start sequence
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });

    // Check auth state and navigate after delay
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is already logged in — go directly to home
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      } else {
        // Not logged in — go to login
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.loginGradient),
        child: Stack(
          children: [
            // Floating orbs
            ..._buildFloatingOrbs(),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryIndigo.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'E',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 42,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: const Text(
                        'ECHO NEWS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'Stay Informed. Stay Ahead.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
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

  List<Widget> _buildFloatingOrbs() {
    return [
      AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          final val = _orbController.value * 2 * pi;
          return Positioned(
            top: -60 + sin(val) * 15,
            right: -60 + cos(val) * 10,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primaryIndigo.withValues(alpha: 0.2),
                  AppColors.primaryIndigo.withValues(alpha: 0.0),
                ]),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          final val = _orbController.value * 2 * pi;
          return Positioned(
            bottom: -80 + cos(val) * 20,
            left: -80 + sin(val) * 12,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accentTeal.withValues(alpha: 0.15),
                  AppColors.accentTeal.withValues(alpha: 0.0),
                ]),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          final val = _orbController.value * 2 * pi;
          return Positioned(
            top: MediaQuery.of(context).size.height * 0.3 + sin(val + 1.5) * 10,
            left: -40 + cos(val + 1.5) * 8,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primaryIndigoLight.withValues(alpha: 0.12),
                  AppColors.primaryIndigoLight.withValues(alpha: 0.0),
                ]),
              ),
            ),
          );
        },
      ),
    ];
  }
}
