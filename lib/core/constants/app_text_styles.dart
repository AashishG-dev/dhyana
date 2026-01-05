// lib/core/constants/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dhyana/core/constants/app_colors.dart';

/// Defines the application's typography system with Google Fonts
class AppTextStyles {
  // --- Display / Headings ---
  static final displayLarge = GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.bold,
  );

  static final displayMedium = GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.bold,
  );

  static final displaySmall = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  static final headlineLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static final headlineMedium = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static final headlineSmall = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static final titleLarge = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );

  static final titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );


  // --- Body text ---
  static final bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static final bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // --- Labels ---
  static final labelLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static final labelMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final labelSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // --- Light theme text ---
  static TextTheme lightTextTheme() {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: AppColors.textLight),
      displayMedium: displayMedium.copyWith(color: AppColors.textLight),
      displaySmall: displaySmall.copyWith(color: AppColors.textLight),
      headlineLarge: headlineLarge.copyWith(color: AppColors.textLight),
      headlineMedium: headlineMedium.copyWith(color: AppColors.textLight),
      headlineSmall: headlineSmall.copyWith(color: AppColors.textLight),
      titleLarge: titleLarge.copyWith(color: AppColors.textLight),
      titleMedium: titleMedium.copyWith(color: AppColors.textLight),
      bodyLarge: bodyLarge.copyWith(color: AppColors.textLight),
      bodyMedium: bodyMedium.copyWith(color: AppColors.textLight),
      bodySmall: bodySmall.copyWith(color: AppColors.textLight),
      labelLarge: labelLarge.copyWith(color: AppColors.textLight),
      labelMedium: labelMedium.copyWith(color: AppColors.textLight),
      labelSmall: labelSmall.copyWith(color: AppColors.textLight),
    );
  }

  // --- Dark theme text ---
  static TextTheme darkTextTheme() {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: AppColors.textDark),
      displayMedium: displayMedium.copyWith(color: AppColors.textDark),
      displaySmall: displaySmall.copyWith(color: AppColors.textDark),
      headlineLarge: headlineLarge.copyWith(color: AppColors.textDark),
      headlineMedium: headlineMedium.copyWith(color: AppColors.textDark),
      headlineSmall: headlineSmall.copyWith(color: AppColors.textDark),
      titleLarge: titleLarge.copyWith(color: AppColors.textDark),
      titleMedium: titleMedium.copyWith(color: AppColors.textDark),
      bodyLarge: bodyLarge.copyWith(color: AppColors.textDark),
      bodyMedium: bodyMedium.copyWith(color: AppColors.textDark),
      bodySmall: bodySmall.copyWith(color: AppColors.textDark),
      labelLarge: labelLarge.copyWith(color: AppColors.textDark),
      labelMedium: labelMedium.copyWith(color: AppColors.textDark),
      labelSmall: labelSmall.copyWith(color: AppColors.textDark),
    );
  }
}
