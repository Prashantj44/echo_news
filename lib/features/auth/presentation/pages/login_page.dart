import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../manager/auth_bloc.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';

/// Professionally designed login page with glass-morphism card,
/// animated background orbs, staggered text animations, and social login buttons.
/// Now wired to Firebase Auth via AuthBloc.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  // Animation controllers
  late final AnimationController _orbController;
  late final AnimationController _fadeController;
  late final AnimationController _cardController;

  late final Animation<double> _welcomeOpacity;
  late final Animation<Offset> _welcomeSlide;
  late final Animation<double> _brandOpacity;
  late final Animation<Offset> _brandSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();

    // Orb floating loop
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Staggered text fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _welcomeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _welcomeSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Card entrance
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    _cardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(const GoogleSignInRequested());
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(PasswordResetRequested(email: email));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Check if user has completed onboarding via Firestore
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is PasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent! Check your inbox.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.loginGradient),
          child: Stack(
            children: [
              // Animated floating orbs
              ..._buildFloatingOrbs(screenHeight),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.08),

                      // ── Welcome Text Section ──
                      _buildHeaderSection(),

                      const SizedBox(height: 36),

                      // ── Glass-morphism Login Card ──
                      _buildLoginCard(),

                      const SizedBox(height: 24),

                      // ── Social Login Section ──
                      _buildSocialSection(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header with staggered animations ──
  Widget _buildHeaderSection() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Column(
          children: [
            SlideTransition(
              position: _welcomeSlide,
              child: FadeTransition(
                opacity: _welcomeOpacity,
                child: Text(
                  'Welcome to',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SlideTransition(
              position: _brandSlide,
              child: FadeTransition(
                opacity: _brandOpacity,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Colors.white, Color(0xFFA5B4FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'ECHO NEWS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.0,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _subtitleOpacity,
              child: Text(
                'Your premium global news experience',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Glass-morphism Login Card ──
  Widget _buildLoginCard() {
    return SlideTransition(
      position: _cardSlide,
      child: FadeTransition(
        opacity: _cardOpacity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your credentials to continue',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            key: ValueKey(_obscurePassword),
                            size: 20,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primaryIndigoLight.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login button with gradient
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: isLoading ? null : AppColors.primaryGradient,
                            color: isLoading ? AppColors.primaryIndigo.withValues(alpha: 0.5) : null,
                            boxShadow: isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.primaryIndigo.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isLoading ? null : _handleLogin,
                              borderRadius: BorderRadius.circular(14),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login_rounded, color: Colors.white, size: 20),
                                          SizedBox(width: 10),
                                          Text(
                                            'Sign In',
                                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sign up prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.signup),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primaryIndigoLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Styled Text Field ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      cursorColor: AppColors.primaryIndigoLight,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.4)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primaryIndigoLight.withValues(alpha: 0.6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.errorBorder, fontSize: 11),
      ),
      validator: validator,
    );
  }

  // ── Social Login Section ──
  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
              ),
            ),
            Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.1))),
          ],
        ),
        const SizedBox(height: 20),
        // Google Sign-In button (functional)
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleGoogleSignIn,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata_rounded, color: Colors.white.withValues(alpha: 0.7), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Floating Background Orbs ──
  List<Widget> _buildFloatingOrbs(double screenHeight) {
    return [
      AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          final val = _orbController.value * 2 * pi;
          return Positioned(
            top: screenHeight * 0.05 + sin(val) * 20,
            right: -50 + cos(val) * 15,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primaryIndigo.withValues(alpha: 0.18),
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
            bottom: screenHeight * 0.1 + cos(val) * 25,
            left: -70 + sin(val) * 18,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accentTeal.withValues(alpha: 0.12),
                  AppColors.accentTeal.withValues(alpha: 0.0),
                ]),
              ),
            ),
          );
        },
      ),
    ];
  }
}
