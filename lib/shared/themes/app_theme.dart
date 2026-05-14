import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF5E46E6);
  static const primaryLight = Color(0xFFF4F3FF);
  static const income = Color(0xFF00B050);
  static const expense = Color(0xFFEA4335);
  static const textDark = Color(0xFF322E73);
  static const textLight = Color(0xFF9EA3C1);
  static const background = Color(0xFFF8F9FE);
  static const cardBackground = Colors.white;
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.inter(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.inter(color: AppColors.textDark),
        bodyMedium: GoogleFonts.inter(color: AppColors.textDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
