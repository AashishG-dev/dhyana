// lib/core/services/meditation_audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:dhyana/core/utils/audio_utils.dart';
import 'package:dhyana/core/services/cloudinary_service.dart';
import 'package:dhyana/models/meditation_model.dart';

/// Manages meditation audio assets, including loading, caching, and providing paths.
class MeditationAudioService {
  final CloudinaryService _cloudinaryService;
  MeditationAudioService(this._cloudinaryService);

  final Map<String, String> _meditationAudioCache = {};

  /// Builds a playable audio URL from a meditation model's public ID.
  String? getAudioUrl(MeditationModel meditation) {
    final meditationId = meditation.id;
    if (meditationId == null) return null;

    // Check cache first
    if (_meditationAudioCache.containsKey(meditationId)) {
      return _meditationAudioCache[meditationId];
    }

    // If not in cache, build it from the model's audioFilePath (which is the Public ID)
    final publicId = meditation.audioFilePath;
    if (publicId != null && publicId.isNotEmpty) {
      final String audioUrl = CloudinaryService.buildCloudinaryUrl(
        publicId: publicId,
        resourceType: CloudinaryResourceType.video, // Audio is stored as a video resource type in Cloudinary
      );
      // Cache the URL for next time
      _meditationAudioCache[meditationId] = audioUrl;
      return audioUrl;
    }
    return null;
  }

  /// Plays a meditation audio from a MeditationModel.
  Future<bool> playMeditation(MeditationModel meditation) async {
    final String? audioUrl = getAudioUrl(meditation);
    if (audioUrl != null) {
      return await AudioUtils.playAudio(audioUrl);
    }
    debugPrint('Cannot play meditation: audio URL not found for ${meditation.id}');
    return false;
  }

  Future<void> pauseMeditation() async {
    await AudioUtils.pauseAudio();
  }

  Future<void> resumeMeditation() async {
    await AudioUtils.resumeAudio();
  }

  Future<void> stopMeditation() async {
    await AudioUtils.stopAudio();
  }

  Future<void> dispose() async {
    await AudioUtils.disposeAudioPlayer();
  }

  // Expose streams from AudioUtils for UI to listen to
  Stream<PlayerState> get onPlayerStateChanged => AudioUtils.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => AudioUtils.onPositionChanged;
  Stream<Duration> get onDurationChanged => AudioUtils.onDurationChanged;
  Stream<void> get onPlayerComplete => AudioUtils.onPlayerComplete;
  Future<void> seek(Duration position) => AudioUtils.seek(position);
}