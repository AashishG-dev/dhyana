// lib/core/services/meditation_audio_service.dart
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:dhyana/core/utils/audio_utils.dart';
import 'package:dhyana/core/services/cloudinary_service.dart';
import 'package:dhyana/models/meditation_model.dart';

class MeditationAudioService {
  final CloudinaryService _cloudinaryService;
  late final AudioPlayer _audioPlayer;

  MeditationAudioService(this._cloudinaryService) {
    // Create a dedicated player instance for meditations
    _audioPlayer = AudioUtils.createPlayer();
    // Meditations can also benefit from this mode
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  final Map<String, String> _meditationAudioCache = {};

  String? getAudioUrl(MeditationModel meditation) {
    // Prioritize local path if it exists
    if (meditation.localAudioPath != null &&
        meditation.localAudioPath!.isNotEmpty) {
      if (File(meditation.localAudioPath!).existsSync()) {
        return meditation.localAudioPath;
      }
    }

    final meditationId = meditation.id;
    if (meditationId == null) return null;

    if (_meditationAudioCache.containsKey(meditationId)) {
      return _meditationAudioCache[meditationId];
    }

    final publicId = meditation.audioFilePath;
    if (publicId != null && publicId.isNotEmpty) {
      final String audioUrl = CloudinaryService.buildCloudinaryUrl(
        publicId: publicId,
        resourceType: CloudinaryResourceType.video,
      );
      _meditationAudioCache[meditationId] = audioUrl;
      return audioUrl;
    }
    return null;
  }

  Future<bool> playMeditation(MeditationModel meditation) async {
    final String? audioUrl = getAudioUrl(meditation);
    if (audioUrl != null) {
      // Check if the URL is a local file path or a network URL
      final bool isLocal = !audioUrl.startsWith('http');
      await _audioPlayer.play(isLocal ? DeviceFileSource(audioUrl) : UrlSource(audioUrl));
      return true;
    }
    debugPrint(
        'Cannot play meditation: audio URL not found for ${meditation.id}');
    return false;
  }

  Future<void> pauseMeditation() async => await _audioPlayer.pause();
  Future<void> resumeMeditation() async => await _audioPlayer.resume();
  Future<void> stopMeditation() async => await _audioPlayer.stop();
  Future<void> dispose() async => await _audioPlayer.dispose();
  Future<void> seek(Duration position) async =>
      await _audioPlayer.seek(position);

  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;
}