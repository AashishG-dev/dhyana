// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/core/services/storage_service.dart'; // For local storage
import 'package:dhyana/core/constants/app_constants.dart'; // For theme mode key

/// A [StateNotifier] that manages the application's theme mode (light or dark).
/// It persists the selected theme mode using `StorageService` (SharedPreferences).
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storageService;

  ThemeNotifier(this._storageService) : super(ThemeMode.system) {
    // Initialize the theme mode from local storage.
    _loadThemeMode();
  }

  /// Loads the saved theme mode from `StorageService`.
  /// If no theme mode is saved, it defaults to `ThemeMode.system`.
  Future<void> _loadThemeMode() async {
    final String? savedTheme = _storageService.getString(AppConstants.themeModeKey);
    if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system; // Default to system theme
    }
    debugPrint('Loaded theme mode: ${state.name}');
  }

  /// Sets the application's theme mode to light.
  Future<void> setLightMode() async {
    state = ThemeMode.light;
    await _storageService.saveString(AppConstants.themeModeKey, 'light');
    debugPrint('Theme set to light mode.');
  }

  /// Sets the application's theme mode to dark.
  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    await _storageService.saveString(AppConstants.themeModeKey, 'dark');
    debugPrint('Theme set to dark mode.');
  }

  /// Toggles the application's theme mode between light and dark.
  /// If the current mode is system, it toggles between light and dark.
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setDarkMode();
    } else if (state == ThemeMode.dark) {
      await setLightMode();
    } else {
      // If system, toggle to light first, then dark on next toggle
      // Or you can choose to directly toggle between light/dark if system is not desired in toggle
      final Brightness platformBrightness =
          WidgetsBinding.instance.window.platformBrightness;
      if (platformBrightness == Brightness.dark) {
        await setLightMode();
      } else {
        await setDarkMode();
      }
    }
    debugPrint('Theme toggled to: ${state.name}');
  }

  /// Sets the application's theme mode to follow the system settings.
  Future<void> setSystemMode() async {
    state = ThemeMode.system;
    await _storageService.saveString(AppConstants.themeModeKey, 'system');
    debugPrint('Theme set to system mode.');
  }
}

/// Provider for the [StorageService].
/// This is needed by the ThemeNotifier to persist theme settings.
final storageServiceProvider = Provider<StorageService>((ref) {
  final storageService = StorageService();
  // Ensure storage service is initialized. This is crucial.
  // In a real app, you might initialize all services in main.dart or a dedicated service initializer.
  // For now, we'll initialize it here if it hasn't been.
  storageService.init(); // Call init, but don't await here directly in a provider definition.
  // The ThemeNotifier's constructor will handle awaiting its _loadThemeMode.
  return storageService;
});


/// The main provider for the application's theme mode.
/// Other widgets can watch this provider to react to theme changes.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ThemeNotifier(storageService);
});
