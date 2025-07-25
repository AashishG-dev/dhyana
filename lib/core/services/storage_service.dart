// lib/core/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding for complex objects
import 'package:flutter/foundation.dart'; // For debugPrint

/// Manages local data persistence, primarily using `shared_preferences`
/// for simple key-value pairs (e.g., user preferences, theme settings)
/// or for caching more complex data as JSON strings.
class StorageService {
  late SharedPreferences _prefs;

  /// Initializes the SharedPreferences instance.
  /// This method must be called and awaited before any other storage operations.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('StorageService initialized.');
  }

  /// Saves a string value to local storage.
  Future<bool> saveString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      debugPrint('Saved string "$value" to key "$key": $result');
      return result;
    } catch (e) {
      debugPrint('Error saving string to key "$key": $e');
      return false;
    }
  }

  /// Retrieves a string value from local storage.
  String? getString(String key) {
    final value = _prefs.getString(key);
    debugPrint('Retrieved string "$value" from key "$key"');
    return value;
  }

  /// Saves a boolean value to local storage.
  Future<bool> saveBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      debugPrint('Saved bool "$value" to key "$key": $result');
      return result;
    } catch (e) {
      debugPrint('Error saving bool to key "$key": $e');
      return false;
    }
  }

  /// Retrieves a boolean value from local storage.
  bool? getBool(String key) {
    final value = _prefs.getBool(key);
    debugPrint('Retrieved bool "$value" from key "$key"');
    return value;
  }

  /// Saves an integer value to local storage.
  Future<bool> saveInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      debugPrint('Saved int "$value" to key "$key": $result');
      return result;
    } catch (e) {
      debugPrint('Error saving int to key "$key": $e');
      return false;
    }
  }

  /// Retrieves an integer value from local storage.
  int? getInt(String key) {
    final value = _prefs.getInt(key);
    debugPrint('Retrieved int "$value" from key "$key"');
    return value;
  }

  /// Saves a double value to local storage.
  Future<bool> saveDouble(String key, double value) async {
    try {
      final result = await _prefs.setDouble(key, value);
      debugPrint('Saved double "$value" to key "$key": $result');
      return result;
    } catch (e) {
      debugPrint('Error saving double to key "$key": $e');
      return false;
    }
  }

  /// Retrieves a double value from local storage.
  double? getDouble(String key) {
    final value = _prefs.getDouble(key);
    debugPrint('Retrieved double "$value" from key "$key"');
    return value;
  }

  /// Saves a list of strings to local storage.
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      final result = await _prefs.setStringList(key, value);
      debugPrint('Saved StringList "$value" to key "$key": $result');
      return result;
    } catch (e) {
      debugPrint('Error saving StringList to key "$key": $e');
      return false;
    }
  }

  /// Retrieves a list of strings from local storage.
  List<String>? getStringList(String key) {
    final value = _prefs.getStringList(key);
    debugPrint('Retrieved StringList "$value" from key "$key"');
    return value;
  }

  /// Saves a complex object to local storage by encoding it to a JSON string.
  /// [key]: The key under which to store the object.
  /// [data]: The object to store (must be serializable to JSON, e.g., a Map).
  Future<bool> saveObject(String key, Map<String, dynamic> data) async {
    try {
      final String jsonString = jsonEncode(data);
      final result = await _prefs.setString(key, jsonString);
      debugPrint('Saved object to key "$key": $result');
      return result;
    } catch (e) {
      debugPrint('Error saving object to key "$key": $e');
      return false;
    }
  }

  /// Retrieves a complex object from local storage by decoding a JSON string.
  /// Returns the decoded object as a Map, or null if not found or decoding fails.
  Map<String, dynamic>? getObject(String key) {
    try {
      final String? jsonString = _prefs.getString(key);
      if (jsonString == null) {
        return null;
      }
      final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('Retrieved object from key "$key"');
      return data;
    } catch (e) {
      debugPrint('Error retrieving or decoding object from key "$key": $e');
      return null;
    }
  }

  /// Removes a specific key-value pair from local storage.
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      debugPrint('Removed key "$key": $result');
      return result;
    } catch (e) {
      debugPrint('Error removing key "$key": $e');
      return false;
    }
  }

  /// Clears all data from local storage. Use with caution.
  Future<bool> clearAll() async {
    try {
      final result = await _prefs.clear();
      debugPrint('Cleared all local storage data: $result');
      return result;
    } catch (e) {
      debugPrint('Error clearing all local storage data: $e');
      return false;
    }
  }
}
