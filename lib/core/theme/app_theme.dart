import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';

class AppTheme {
  /// Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      textTheme: AppTextStyles.lightTextTheme(),
      fontFamily: 'Poppins',

      scaffoldBackgroundColor: AppColors.backgroundLight,

      // --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.textLight),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),

      // --- Card ---
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.9),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(AppConstants.marginSmall),
      ),

      // --- ElevatedButton ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          backgroundColor: AppColors.primaryLightBlue,
          foregroundColor: Colors.white,
          elevation: 3,
        ),
      ),

      // --- BottomNavigationBar ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        selectedItemColor: AppColors.primaryLightBlue,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  /// Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTextStyles.darkTextTheme(),
      fontFamily: 'Poppins',

      scaffoldBackgroundColor: AppColors.backgroundDark,

      // --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: Colors.white),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // --- Card ---
      cardTheme: CardThemeData(
        color: AppColors.glassDarkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(AppConstants.marginSmall),
      ),

      // --- ElevatedButton ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          backgroundColor: AppColors.primaryLightGreen,
          foregroundColor: Colors.black,
          elevation: 3,
        ),
      ),

      // --- BottomNavigationBar ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
        selectedItemColor: AppColors.primaryLightGreen,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
