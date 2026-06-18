import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography scale for Echo News.
/// All text widgets should reference these styles.
class AppTextStyles {
  AppTextStyles._();

  // ── Headlines ──
  static TextStyle headline1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.slateDark,
    height: 1.2,
  );

  static TextStyle headline2 = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.slateDark,
    height: 1.3,
  );

  static TextStyle headline3 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.slateDark,
    height: 1.4,
  );

  // ── Titles ──
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.slateDark,
    letterSpacing: 1.5,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.slateDark,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.slate700,
  );

  // ── Body ──
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.slate700,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slate700,
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.slate600,
    height: 1.4,
  );

  // ── Captions / Labels ──
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slate500,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.slate500,
  );

  static TextStyle labelBold = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );

  // ── Overline / Badges ──
  static TextStyle overline = GoogleFonts.inter(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.slate500,
  );

  static TextStyle badge = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );

  // ── Button ──
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
}
