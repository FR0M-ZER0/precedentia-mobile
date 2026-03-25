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
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.mainDarkColor,
        ),

        // Title medium: Merriweather Bold 24px
        titleMedium: GoogleFonts.merriweather(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.mainDarkColor,
        ),

        // Subtitle: IBM Plex Sans Regular 16px
        titleSmall: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.02,
          color: AppColors.altDarkColor,
        ),

        // Subtitle small: IBM Plex Sans Regular 16px
        labelSmall: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.altDarkColor,
        ),

        // Section title: IBM Plex Sans Medium 14px
        headlineMedium: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.mainDarkColor,
        ),

        // Body text: IBM Plex Sans Regular 16px
        bodyMedium: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.32,
          height: 1.875,
          color: AppColors.mainDarkColor,
        ),

        // Functional: IBM Plex Sans Medium 16px
        displayMedium: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.96,
          color: AppColors.altDarkColor,
        ),

        // Text large small tracking: IBM Plex Sans Medium 20px
        bodyLarge: GoogleFonts.ibmPlexSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: AppColors.altDarkColor,
        ),

        // Text large: IBM Plex Sans Medium 20px
        displayLarge: GoogleFonts.ibmPlexSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.6,
          color: AppColors.mainDarkColor,
        ),

        // Text normal: IBM Plex Sans Regular 14px
        displaySmall: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.28,
          color: AppColors.mainDarkColor,
        ),

        // Text small: IBM Plex Sans Regular 12px
        bodySmall: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.24,
          color: AppColors.altDarkColor,
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
