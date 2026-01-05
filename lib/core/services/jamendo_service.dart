// lib/core/services/jamendo_service.dart
import 'dart:convert';
import 'package:dhyana/models/music_track_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dhyana/core/constants/app_constants.dart';

class JamendoService {
  final String _clientId = AppConstants.jamendoClientId;
  final String _baseUrl = AppConstants.jamendoApiBaseUrl;

  Future<List<MusicTrackModel>> searchMusic({
    required String query,
    int limit = 20,
  }) async {
    final encodedQuery = Uri.encodeComponent(query);

    // ✅ UPDATED: Changed from 'mp32' (96k) to 'mp31' (64k) for maximum speed.
    final url = Uri.parse('$_baseUrl/tracks/?client_id=$_clientId&format=jsonpretty&limit=$limit&search=$encodedQuery&audioformat=mp31');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        return results
            .map((trackJson) => MusicTrackModel.fromJamendoJson(trackJson))
            .where((track) => track.audioUrl.isNotEmpty)
            .toList();
      } else {
        debugPrint('Jamendo API Error: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load music from Jamendo');
      }
    } catch (e) {
      debugPrint('Error fetching from Jamendo: $e');
      throw Exception('Failed to connect to Jamendo');
    }
  }
}