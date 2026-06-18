import 'package:flutter/material.dart';

/// Centralized color palette for Echo News.
/// All UI components should reference these tokens instead of inline Color literals.
class AppColors {
  AppColors._();

  // ── Primary Brand ──
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryIndigoLight = Color(0xFF6366F1);
  static const Color primaryIndigoDark = Color(0xFF3730A3);

  // ── Accent ──
  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentTealLight = Color(0xFF14B8A6);

  // ── Neutrals / Slate ──
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // ── Surfaces ──
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;

  // ── Semantic ──
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFCA5A5);
  static const Color errorDark = Color(0xFF991B1B);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color successDark = Color(0xFF065F46);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFF92400E);

  // ── Category Colors ──
  static const Color categoryRose = Color(0xFFE11D48);
  static const Color categoryBlue = Color(0xFF2563EB);
  static const Color categoryAmber = Color(0xFFD97706);
  static const Color categoryGreen = Color(0xFF16A34A);
  static const Color categoryPurple = Color(0xFF9333EA);
  static const Color categorySky = Color(0xFF0284C7);
  static const Color categoryPink = Color(0xFFDB2777);
  static const Color categoryOrange = Color(0xFFEA580C);
  static const Color categoryCyan = Color(0xFF0891B2);

  // ── Gradient Presets ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E1B4B),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E1B4B),
      Color(0xFF0F172A),
    ],
  );
}
