// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

/// Centralized definition of the application's color palette,
/// ensuring consistency across the UI and supporting the Glass Morphism theme.
///
/// Glass Morphism typically involves translucent backgrounds, blur effects,
/// and subtle borders, often using light colors for the "glass" effect.
/// The colors defined here will support both light and dark themes,
/// adapting to the glass morphism aesthetic.
class AppColors {
  // --- Primary Colors (Calming blues and greens) ---
  static const Color primaryLightBlue = Color(0xFF64B5F6); // Light Blue
  static const Color primaryLightGreen = Color(0xFF81C784); // Light Green

  // --- Secondary Colors (Warm earth tones) ---
  static const Color secondaryOrange = Color(0xFFFFB74D); // Orange
  static const Color secondaryBrown = Color(0xFFA1887F); // Brown

  // --- Accent Colors (Soft pastels for highlights) ---
  static const Color accentLightCyan = Color(0xFFE0F2F7); // Light Cyan
  static const Color accentPink = Color(0xFFF8BBD0); // Pink

  // --- Background Colors ---
  // For Glass Morphism, these backgrounds will often be the "backdrop"
  // against which translucent elements sit.
  static const Color backgroundLight = Color(0xFFFFFFFF); // White for light mode
  static const Color backgroundDark = Color(0xFF121212); // Dark grey for dark mode

  // --- Text Colors (High contrast for readability) ---
  static const Color textLight = Color(0xFF212121); // Dark grey for text on light backgrounds
  static const Color textDark = Color(0xFFE0E0E0); // Light grey for text on dark backgrounds
  static const Color textAccent = Color(0xFF42A5F5); // A vibrant blue for links/accents

  // --- Glass Morphism Specific Colors (Translucent effects) ---
  // These colors are designed to be used with opacity for the glass effect.
  // They are typically lighter shades that allow background elements to show through.
  static const Color glassLightSurface = Color(0x33FFFFFF); // White with 20% opacity for light glass
  static const Color glassDarkSurface = Color(0x33212121); // Dark grey with 20% opacity for dark glass

  // Subtle border color for glass elements
  static const Color glassBorderLight = Color(0x1AFFFFFF); // Very subtle white border
  static const Color glassBorderDark = Color(0x1A000000); // Very subtle black border

  // --- Status Colors ---
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFEF5350); // Red
  static const Color warningColor = Color(0xFFFFCA28); // Amber
  static const Color infoColor = Color(0xFF2196F3); // Blue

  // --- Color Scheme Definitions (for ThemeData) ---

  /// Defines the ColorScheme for the light theme.
  static ColorScheme lightColorScheme = const ColorScheme.light(
    primary: primaryLightBlue,
    onPrimary: backgroundLight, // Text/icons on primary color
    secondary: secondaryOrange,
    onSecondary: backgroundLight, // Text/icons on secondary color
    surface: backgroundLight, // Card/dialog backgrounds
    onSurface: textLight, // Text/icons on surface
    background: backgroundLight, // Main screen background
    onBackground: textLight, // Text/icons on background
    error: errorColor,
    onError: backgroundLight,
    brightness: Brightness.light,
  );

  /// Defines the ColorScheme for the dark theme.
  static ColorScheme darkColorScheme = const ColorScheme.dark(
    primary: primaryLightGreen, // Can be a different primary for dark mode
    onPrimary: backgroundDark,
    secondary: secondaryBrown,
    onSecondary: backgroundDark,
    surface: Color(0xFF1E1E1E), // Darker surface for cards/dialogs in dark mode
    onSurface: textDark,
    background: backgroundDark,
    onBackground: textDark,
    error: errorColor,
    onError: backgroundDark,
    brightness: Brightness.dark,
  );
}
