import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../manager/auth_bloc.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';

/// Sign-up page with the same glass-morphism design as login.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AnimationController _orbController;
  late final AnimationController _cardController;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

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

    _cardController.forward();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _cardController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(SignUpRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
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
              ..._buildFloatingOrbs(screenHeight),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.06),

                      // Header
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Colors.white, Color(0xFFA5B4FC)],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'ECHO NEWS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Join the global news community',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Glass card
                      SlideTransition(
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
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Create your account to get started',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Name
                                      _buildField(
                                        controller: _nameController,
                                        label: 'Full Name',
                                        hint: 'John Doe',
                                        icon: Icons.person_outline_rounded,
                                        validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                                      ),
                                      const SizedBox(height: 14),

                                      // Email
                                      _buildField(
                                        controller: _emailController,
                                        label: 'Email Address',
                                        hint: 'you@example.com',
                                        icon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'Email is required';
                                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                                            return 'Enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Password
                                      _buildField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hint: '••••••••',
                                        icon: Icons.lock_outline_rounded,
                                        obscure: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                            size: 20,
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Password is required';
                                          if (v.length < 6) return 'Minimum 6 characters';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      // Confirm Password
                                      _buildField(
                                        controller: _confirmPasswordController,
                                        label: 'Confirm Password',
                                        hint: '••••••••',
                                        icon: Icons.lock_outline_rounded,
                                        obscure: _obscureConfirm,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                            size: 20,
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                        ),
                                        validator: (v) {
                                          if (v != _passwordController.text) return 'Passwords do not match';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),

                                      // Sign Up Button
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          final isLoading = state is AuthLoading;
                                          return Container(
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
                                                onTap: isLoading ? null : _handleSignUp,
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
                                                            Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Create Account',
                                                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
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

                                      // Sign in link
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account? ',
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                                          ),
                                          GestureDetector(
                                            onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.login),
                                            child: const Text(
                                              'Sign In',
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
                      ),
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

  Widget _buildField({
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
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
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
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryIndigo.withValues(alpha: 0.18),
                    AppColors.primaryIndigo.withValues(alpha: 0.0),
                  ],
                ),
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
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentTeal.withValues(alpha: 0.12),
                    AppColors.accentTeal.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
}
