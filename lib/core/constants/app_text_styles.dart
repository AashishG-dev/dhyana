// lib/core/constants/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart'; // Import AppColors for consistent text colors

/// Defines the application's typography system, including font families,
/// sizes, weights, and letter spacing. This ensures consistent typography
/// across all UI components and screens, adapting for both light and dark modes.
class AppTextStyles {
  // Define a base font family if you're using a custom font.
  // For now, we'll use the default system font.
  static const String _fontFamily = 'Inter'; // As per general instructions, use Inter if not specified.

  // --- Heading Styles ---
  static TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.textLight, // Default for light theme, will be overridden by ThemeData
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  // --- Title Styles ---
  static TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500, // Medium weight for titles
    color: AppColors.textLight,
  );

  static TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textLight,
  );

  static TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textLight,
  );

  // --- Body Styles ---
  static TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textLight,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textLight,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textLight,
  );

  // --- Label Styles (for buttons, input hints etc.) ---
  static TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    color: AppColors.textLight,
  );

  static TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textLight,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textLight,
  );

  // --- Button Text Style (often uses labelLarge or custom) ---
  static TextStyle buttonText = labelLarge.copyWith(
    color: AppColors.backgroundLight, // Buttons usually have light text on dark background
  );

  // --- Caption Style (for small, secondary text) ---
  static TextStyle caption = bodySmall.copyWith(
    color: AppColors.textLight.withOpacity(0.7), // Slightly faded
  );

  // --- Overline Style (very small, uppercase text) ---
  static TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    color: AppColors.textLight,
  );

  // Helper to get text style for dark theme (to be used in ThemeData)
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
      titleSmall: titleSmall.copyWith(color: AppColors.textDark),
      bodyLarge: bodyLarge.copyWith(color: AppColors.textDark),
      bodyMedium: bodyMedium.copyWith(color: AppColors.textDark),
      bodySmall: bodySmall.copyWith(color: AppColors.textDark),
      labelLarge: labelLarge.copyWith(color: AppColors.textDark),
      labelMedium: labelMedium.copyWith(color: AppColors.textDark),
      labelSmall: labelSmall.copyWith(color: AppColors.textDark),
      // Specific overrides for button and caption if needed for dark theme
      // button: buttonText.copyWith(color: AppColors.backgroundDark), // Example
      // caption: caption.copyWith(color: AppColors.textDark.withOpacity(0.7)), // Example
    );
  }

  // Helper to get text style for light theme (to be used in ThemeData)
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
      titleSmall: titleSmall.copyWith(color: AppColors.textLight),
      bodyLarge: bodyLarge.copyWith(color: AppColors.textLight),
      bodyMedium: bodyMedium.copyWith(color: AppColors.textLight),
      bodySmall: bodySmall.copyWith(color: AppColors.textLight),
      labelLarge: labelLarge.copyWith(color: AppColors.textLight),
      labelMedium: labelMedium.copyWith(color: AppColors.textLight),
      labelSmall: labelSmall.copyWith(color: AppColors.textLight),
      // Specific overrides for button and caption if needed for light theme
      // button: buttonText.copyWith(color: AppColors.backgroundLight), // Example
      // caption: caption.copyWith(color: AppColors.textLight.withOpacity(0.7)), // Example
    );
  }
}
