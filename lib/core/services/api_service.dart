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
  // This is configured in AppConstants.
  final String _geminiApiBaseUrl = AppConstants.geminiApiBaseUrl;

  // Base URL for Cloudinary API (for direct API calls, if needed for unsigned uploads or specific management).
  // For most asset delivery, direct URLs are used. For signed uploads, CloudinaryService will handle it.
  final String _cloudinaryBaseUrl = 'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/';

  // Private helper to construct full URL
  Uri _getUri(String path, {String? baseUrl}) {
    final base = baseUrl ?? _geminiApiBaseUrl; // Default to Gemini API base URL
    return Uri.parse('$base$path');
  }

  /// Performs an HTTP GET request.
  ///
  /// [path]: The API endpoint path (e.g., 'models').
  /// [headers]: Optional HTTP headers to include in the request.
  /// [baseUrl]: Optional base URL override. Defaults to Gemini API base URL.
  ///
  /// Returns a decoded JSON response or throws an [Exception] on error.
  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? headers, String? baseUrl}) async {
    final uri = _getUri(path, baseUrl: baseUrl);
    debugPrint('GET Request to: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error during GET request to $uri: $e');
      rethrow; // Re-throw the exception for higher-level error handling
    }
  }

  /// Performs an HTTP POST request.
  ///
  /// [path]: The API endpoint path (e.g., 'v1beta/models/gemini-pro:generateContent').
  /// [body]: The request body, which will be JSON-encoded.
  /// [headers]: Optional HTTP headers to include in the request.
  /// [baseUrl]: Optional base URL override. Defaults to Gemini API base URL.
  ///
  /// Returns a decoded JSON response or throws an [Exception] on error.
  Future<Map<String, dynamic>> post(String path, dynamic body,
      {Map<String, String>? headers, String? baseUrl}) async {
    final uri = _getUri(path, baseUrl: baseUrl);
    debugPrint('POST Request to: $uri with body: ${jsonEncode(body)}');

    // Default headers, including Content-Type for JSON
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      ...?headers, // Merge provided headers, allowing them to override defaults
    };

    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(body), // Encode the body to JSON string
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error during POST request to $uri: $e');
      rethrow;
    }
  }

  /// Handles the HTTP response, checking for success and parsing JSON.
  ///
  /// [response]: The HTTP response object.
  ///
  /// Returns a decoded JSON response if successful.
  /// Throws an [Exception] with an error message if the response status is not 2xx.
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success: Decode the JSON response
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // Error: Extract error message from response body if available, otherwise use status code
      String errorMessage = 'Request failed with status: ${response.statusCode}.';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('error')) {
          errorMessage = errorBody['error']['message'] ?? errorMessage;
        } else if (errorBody is Map && errorBody.containsKey('message')) {
          errorMessage = errorBody['message'] ?? errorMessage;
        }
      } catch (e) {
        // Ignore JSON parsing errors if the response body isn't JSON
        debugPrint('Failed to parse error response body: $e');
      }
      throw Exception(errorMessage);
    }
  }
}
