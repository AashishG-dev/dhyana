// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/core/services/storage_service.dart';

// The new AsyncNotifierProvider for the theme
final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  late StorageService _storageService;

  // The build method is called automatically and handles the initial async loading
  @override
  Future<ThemeMode> build() async {
    _storageService = ref.watch(storageServiceProvider);
    return _loadThemeMode();
  }

  Future<ThemeMode> _loadThemeMode() async {
    final themeString = _storageService.getThemeMode();
    switch (themeString) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  // Method to change the theme
  Future<void> setThemeMode(ThemeMode mode) async {
    state = const AsyncValue.loading(); // Set loading state
    state = await AsyncValue.guard(() async { // Save and update state
      String themeString;
      switch (mode) {
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.light:
          themeString = 'light';
          break;
        default:
          themeString = 'system';
          break;
      }
      await _storageService.setThemeMode(themeString);
      return mode;
    });
  }
}