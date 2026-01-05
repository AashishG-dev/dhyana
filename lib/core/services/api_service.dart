// lib/core/services/api_service.dart
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:dhyana/core/constants/app_constants.dart'; // For API base URLs

/// A centralized HTTP client for making external API calls, primarily to
/// the Gemini API for chatbot functionality and potentially other external services.
/// Handles common headers, error responses, and JSON parsing.
class ApiService {
  // Base URL for the Gemini API.
  final String geminiApiBaseUrl = AppConstants.geminiApiBaseUrl;

  // Base URL for Cloudinary API.
  final String cloudinaryBaseUrl =
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/';

  // ✅ UPDATED: This method now searches Pexels instead of Pixabay
  Future<String> searchForImage(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        '${AppConstants.pexelsApiBaseUrl}search?query=$encodedQuery&per_page=1&orientation=landscape');

    try {
      final response = await http.get(
        url,
        // Pexels API requires an Authorization header
        headers: {'Authorization': AppConstants.pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['photos'] != null && (data['photos'] as List).isNotEmpty) {
          // Return the URL for a suitably sized landscape image
          return data['photos'][0]['src']['large'];
        }
      }
      // If no image is found or there's an error, return a default placeholder
      return AppConstants.defaultPlaceholderImageUrl;
    } catch (e) {
      debugPrint('❌ Error searching for image on Pexels: $e');
      return AppConstants.defaultPlaceholderImageUrl;
    }
  }

  // Private helper to construct full URL
  Uri _getUri(String path, {String? baseUrl}) {
    final base = baseUrl ?? geminiApiBaseUrl;
    return Uri.parse('$base$path');
  }

  /// Performs an HTTP GET request.
  /// Always returns `Map<String, dynamic>` or throws.
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? headers,
        String? baseUrl,
      }) async {
    final uri = _getUri(path, baseUrl: baseUrl);
    debugPrint('GET Request to: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error during GET request to $uri: $e');
      rethrow;
    }
  }

  /// Performs an HTTP POST request.
  /// Always returns `Map<String, dynamic>` or throws.
  Future<Map<String, dynamic>> post(
      String path,
      Map<String, dynamic> body, {
        Map<String, String>? headers,
        String? baseUrl,
      }) async {
    final uri = _getUri(path, baseUrl: baseUrl);
    debugPrint('POST Request to: $uri with headers: $headers');

    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ Error during POST request to $uri: $e');
      rethrow;
    }
  }

  /// Handles the HTTP response, checking for success and parsing JSON.
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception('Expected JSON object but got ${decoded.runtimeType}');
        }
      } catch (e) {
        throw Exception('Failed to parse JSON response: $e');
      }
    } else {
      String errorMessage =
          'Request failed with status: ${response.statusCode}.';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('error')) {
          errorMessage = errorBody['error']['message'] ?? errorMessage;
        } else if (errorBody is Map && errorBody.containsKey('message')) {
          errorMessage = errorBody['message'] ?? errorMessage;
        }
      } catch (e) {
        debugPrint('Failed to parse error response body: $e');
      }
      throw Exception(errorMessage);
    }
  }
}