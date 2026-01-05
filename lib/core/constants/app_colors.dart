// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

/// Centralized definition of the application's color palette.
class AppColors {
  // --- Primary Colors (NEW Light Theme Palette) ---
  static const Color primaryTeal = Color(0xFF26A69A); // A calming, vibrant teal
  static const Color primarySkyBlue = Color(0xFF4FC3F7); // A bright, clear sky blue

  // --- Accent Colors ---
  static const Color accentCoral = Color(0xFFFF7F50); // A warm, energetic coral/pink
  static const Color accentLime = Color(0xFFD4E157); // A fresh, earthy lime green

  // --- Colors from Previous Theme (kept for compatibility) ---
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryBlue = Color(0xFF3A86FF);
  static const Color primaryLightBlue = Color(0xFF4FC3F7); // NOW USES NEW SKY BLUE
  static const Color primaryLightPurple = Color(0xFFB39DDB);
  static const Color primaryLightGreen = Color(0xFF81C784);
  static const Color accentPink = Color(0xFFFF6B81);
  static const Color accentCyan = Color(0xFF64DFDF);

  // --- Background Colors ---
  static const Color backgroundLight = Color(0xFFF7F9FC); // A very light, clean blue-gray
  static const Color backgroundDark = Color(0xFF1C1B29); // Dark indigo

  // --- Text Colors ---
  static const Color textLight = Color(0xFF1F2937); // A softer, modern dark gray for text
  static const Color textDark = Color(0xFFE0E0E0);

  // --- Glass Morphism Surfaces ---
  static const Color glassLightSurface = Color(0x4DFFFFFF);
  static const Color glassDarkSurface = Color(0x33212121);
  static const Color glassBorderLight = Color(0x33D1D5DB);
  static const Color glassBorderDark = Color(0x1A000000);

  // --- Status Colors ---
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color warningColor = Color(0xFFFFCA28);
  static const Color infoColor = Color(0xFF2196F3);

  // --- Gradient ---
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryTeal, primarySkyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ✅ ADDED: Dynamic Gradients for Header
  static const LinearGradient morningGradient = LinearGradient(
    colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient afternoonGradient = LinearGradient(
    colors: [Color(0xFFF6D365), Color(0xFFFDA085)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient eveningGradient = LinearGradient(
    colors: [Color(0xFF485563), Color(0xFF29323C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Color Schemes ---
  static ColorScheme lightColorScheme = const ColorScheme.light(
    primary: primaryTeal,
    onPrimary: Colors.white,
    secondary: accentCoral,
    onSecondary: Colors.white,
    surface: backgroundLight,
    onSurface: textLight,
    background: backgroundLight,
    onBackground: textLight,
    error: errorColor,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  static ColorScheme darkColorScheme = const ColorScheme.dark(
    primary: primaryBlue,
    onPrimary: backgroundDark,
    secondary: accentCyan,
    onSecondary: backgroundDark,
    surface: Color(0xFF1E1E2F),
    onSurface: textDark,
    background: backgroundDark,
    onBackground: textDark,
    error: errorColor,
    onError: backgroundDark,
    brightness: Brightness.dark,
  );
}