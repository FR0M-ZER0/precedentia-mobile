// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Usar ColorScheme.fromSeed garante que os widgets do Flutter
      // (como botões e switches) usem sua paleta.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mainDarkColor,
        primary: AppColors.mainDarkColor,
        secondary: AppColors.accentColor,
        surface: AppColors.mainWhiteColor,
        background: AppColors.mainWhiteColor,
        error: AppColors.detailsColor,
      ),
      scaffoldBackgroundColor: AppColors.mainWhiteColor,

      textTheme: TextTheme(
        // Title: Merriweather Bold 28px
        titleLarge: GoogleFonts.merriweather(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.mainDarkColor,
          letterSpacing: 0.02,
          height: 1.0,
        ),
        // Title: Merriweather Bold 28px
        titleMedium: GoogleFonts.merriweather(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.mainDarkColor,
          height: 1.0,
        ),

        // Subtitle: IBM Plex Sans Regular 16px
        titleSmall: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.02,
          height: 1.0,
          color: AppColors.altDarkColor,
        ),
        // TextSmall: IBM Plex Sans Regular 12px
        bodySmall: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.02,
          height: 1.0,
          color: AppColors.altDarkColor,
        ),
        // Corpo: IBM Plex Sans SemiBold 42px
        displayLarge: GoogleFonts.ibmPlexSans(
          fontSize: 42,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.02,
          height: 1.0,
          color: AppColors.mainDarkColor,
        ),
      ),

      // Padronização da AppBar global
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mainDarkColor,
        foregroundColor: AppColors.mainWhiteColor,
        elevation: 0,
      ),
    );
  }
}
