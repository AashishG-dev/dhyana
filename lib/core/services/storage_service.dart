// lib/core/services/storage_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

// This provider is now designed to be overridden in main.dart
// This ensures that the StorageService is initialized with a ready-to-use
// SharedPreferences instance, preventing race conditions.
final storageServiceProvider = Provider<StorageService>((ref) {
  // This line will throw an error if the provider is not overridden in main.dart,
  // which is a good safeguard to ensure correct app initialization.
  throw UnimplementedError('storageServiceProvider must be overridden in the ProviderScope');
});

class StorageService {
  final SharedPreferences _prefs;

  // The constructor now directly accepts the SharedPreferences instance.
  StorageService(this._prefs);

  // --- Generic Methods ---

  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  Future<bool> saveString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    return _prefs.setString(key, jsonEncode(json));
  }

  Map<String, dynamic>? getJson(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> jsonList) {
    final stringList = jsonList.map((json) => jsonEncode(json)).toList();
    return _prefs.setStringList(key, stringList);
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final stringList = _prefs.getStringList(key);
    if (stringList != null) {
      return stringList.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
    }
    return null;
  }

  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  // --- Specific Methods ---

  String? getThemeMode() {
    try {
      return _prefs.getString('theme_mode');
    } catch (e) {
      debugPrint('Could not retrieve theme mode: $e');
      return null;
    }
  }

  Future<bool> setThemeMode(String themeMode) async {
    return _prefs.setString('theme_mode', themeMode);
  }
}
