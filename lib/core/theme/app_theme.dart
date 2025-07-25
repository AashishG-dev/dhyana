// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart'; // For border radius and other constants

/// Configures the complete ThemeData for the application,
/// including color schemes, typography, button themes, and other visual properties.
/// This class defines both light and dark themes, incorporating the
/// Glass Morphism aesthetic through specific component styling.
class AppTheme {
  /// Returns the ThemeData for the light theme.
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      // Use the light color scheme defined in AppColors
      colorScheme: AppColors.lightColorScheme,
      // Use the light text theme defined in AppTextStyles
      textTheme: AppTextStyles.lightTextTheme(),
      fontFamily: 'Inter', // Ensure consistent font family

      // --- AppBar Theme ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8), // Slightly translucent for glass effect
        foregroundColor: AppColors.textLight,
        elevation: 0, // No shadow for a flatter, modern look
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(color: AppColors.textLight),
      ),

      // --- Card Theme (for Glass Morphism) ---
      cardTheme: CardThemeData( // Corrected to CardThemeData
        color: AppColors.glassLightSurface, // Translucent white for light glass
        elevation: 4, // Subtle shadow for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          side: BorderSide(color: AppColors.glassBorderLight, width: 1.0), // Subtle border
        ),
        margin: const EdgeInsets.all(AppConstants.marginSmall), // Default margin for cards
        // padding: const EdgeInsets.all(AppConstants.paddingMedium), // Removed as per error
      ),

      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLightBlue,
          foregroundColor: AppColors.backgroundLight,
          textStyle: AppTextStyles.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
          elevation: 3, // Subtle shadow
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLightBlue,
          textStyle: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.w400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLightBlue,
          textStyle: AppTextStyles.buttonText,
          side: const BorderSide(color: AppColors.primaryLightBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
        ),
      ),

      // --- Input Decoration Theme (for TextFields) ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassLightSurface, // Translucent background for inputs
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.glassBorderLight, width: 1.0), // Subtle border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.glassBorderLight, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryLightBlue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight.withOpacity(0.7)),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight.withOpacity(0.5)),
      ),

      // --- Bottom Navigation Bar Theme ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8), // Translucent
        selectedItemColor: AppColors.primaryLightBlue,
        unselectedItemColor: AppColors.textLight.withOpacity(0.6),
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 8, // Subtle elevation
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
      ),

      // --- Dialog Theme ---
      dialogTheme: DialogThemeData( // Corrected to DialogThemeData
        backgroundColor: AppColors.glassLightSurface, // Translucent background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          side: BorderSide(color: AppColors.glassBorderLight, width: 1.0),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.textLight),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
      ),

      // --- Floating Action Button Theme ---
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLightBlue,
        foregroundColor: AppColors.backgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), // More rounded
        ),
        elevation: 6,
      ),

      // --- Slider Theme (for progress, duration) ---
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLightBlue,
        inactiveTrackColor: AppColors.primaryLightBlue.withOpacity(0.3),
        thumbColor: AppColors.primaryLightBlue,
        overlayColor: AppColors.primaryLightBlue.withOpacity(0.2),
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
      ),

      // --- Switch Theme ---
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLightGreen;
          }
          return AppColors.textLight.withOpacity(0.6);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLightGreen.withOpacity(0.5);
          }
          return AppColors.textLight.withOpacity(0.3);
        }),
      ),
    );
  }

  /// Returns the ThemeData for the dark theme.
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      // Use the dark color scheme defined in AppColors
      colorScheme: AppColors.darkColorScheme,
      // Use the dark text theme defined in AppTextStyles
      textTheme: AppTextStyles.darkTextTheme(),
      fontFamily: 'Inter', // Ensure consistent font family

      // --- AppBar Theme ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark.withOpacity(0.8), // Slightly translucent for glass effect
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(color: AppColors.textDark),
      ),

      // --- Card Theme (for Glass Morphism) ---
      cardTheme: CardThemeData( // Corrected to CardThemeData
        color: AppColors.glassDarkSurface, // Translucent dark grey for dark glass
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          side: BorderSide(color: AppColors.glassBorderDark, width: 1.0), // Subtle border
        ),
        margin: const EdgeInsets.all(AppConstants.marginSmall),
        // padding: const EdgeInsets.all(AppConstants.paddingMedium), // Removed as per error
      ),

      // --- Button Themes ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLightGreen, // Different primary for dark mode
          foregroundColor: AppColors.backgroundDark,
          textStyle: AppTextStyles.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
          elevation: 3,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLightGreen,
          textStyle: AppTextStyles.buttonText.copyWith(fontWeight: FontWeight.w400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLightGreen,
          textStyle: AppTextStyles.buttonText,
          side: const BorderSide(color: AppColors.primaryLightGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
        ),
      ),

      // --- Input Decoration Theme (for TextFields) ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassDarkSurface, // Translucent background for inputs
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.glassBorderDark, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.glassBorderDark, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryLightGreen, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2.0),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark.withOpacity(0.7)),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark.withOpacity(0.5)),
      ),

      // --- Bottom Navigation Bar Theme ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark.withOpacity(0.8), // Translucent
        selectedItemColor: AppColors.primaryLightGreen,
        unselectedItemColor: AppColors.textDark.withOpacity(0.6),
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // --- Dialog Theme ---
      dialogTheme: DialogThemeData( // Corrected to DialogThemeData
        backgroundColor: AppColors.glassDarkSurface, // Translucent background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          side: BorderSide(color: AppColors.glassBorderDark, width: 1.0),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.textDark),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
      ),

      // --- Floating Action Button Theme ---
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLightGreen,
        foregroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        elevation: 6,
      ),

      // --- Slider Theme (for progress, duration) ---
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLightGreen,
        inactiveTrackColor: AppColors.primaryLightGreen.withOpacity(0.3),
        thumbColor: AppColors.primaryLightGreen,
        overlayColor: AppColors.primaryLightGreen.withOpacity(0.2),
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
      ),

      // --- Switch Theme ---
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLightBlue; // Can use primaryLightBlue for contrast in dark mode
          }
          return AppColors.textDark.withOpacity(0.6);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLightBlue.withOpacity(0.5);
          }
          return AppColors.textDark.withOpacity(0.3);
        }),
      ),
    );
  }
}
