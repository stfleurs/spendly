import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0F4C81);
  static const primaryLight = Color(0xFFE8F1FA);
  static const income = Color(0xFF0C9B63);
  static const expense = Color(0xFFD64545);
  static const textDark = Color(0xFF172B4D);
  static const textLight = Color(0xFF6B7A90);
  static const background = Color(0xFFF3F7FB);
  static const cardBackground = Colors.white;
  static const navShadow = Color(0x1420324A);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.cardBackground,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.dmSans(color: AppColors.textDark),
        bodyMedium: GoogleFonts.dmSans(color: AppColors.textDark),
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
