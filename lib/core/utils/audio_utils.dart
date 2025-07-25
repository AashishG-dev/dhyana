// lib/core/utils/audio_utils.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For audio playback

/// Utilities for audio playback and management, specifically for meditation sessions.
/// This class will handle loading audio assets, managing playback state,
/// and potentially handling audio focus (though basic implementation here).
class AudioUtils {
  // An instance of AudioPlayer to manage audio playback.
  static AudioPlayer _audioPlayer = AudioPlayer();

  // A list to store paths or identifiers of loaded meditation audios.
  // In a real application, these might be Cloudinary URLs or local paths.
  static List<String> _loadedMeditationAudios = [];

  /// Initializes the audio player. This should ideally be called once,
  /// perhaps during app startup or when the audio service is initialized.
  static void initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    // You can set various audio player configurations here, e.g.,
    // _audioPlayer.setReleaseMode(ReleaseMode.stop); // Stop and release resources when finished
    // _audioPlayer.setVolume(1.0); // Set initial volume
  }

  /// Loads meditation audios. In this simplified example, it just populates
  /// a dummy list. In a real scenario, this would fetch actual audio paths
  /// (e.g., from Cloudinary or local assets).
  ///
  /// For Cloudinary: You would typically fetch a list of audio public IDs
  /// or direct URLs from your backend (Firestore) and then use CloudinaryService
  /// to construct playable URLs if needed.
  static Future<void> loadMeditationAudios() async {
    // Simulate loading audio paths/URLs.
    // Replace with actual logic to fetch audio URLs from Cloudinary or local assets.
    _loadedMeditationAudios = [
      'https://res.cloudinary.com/your_cloud_name/video/upload/v1234567890/meditations/calm_breathing.mp3',
      'https://res.cloudinary.com/your_cloud_name/video/upload/v1234567890/meditations/mindful_walk.mp3',
      'https://res.cloudinary.com/your_cloud_name/video/upload/v1234567890/meditations/sleep_aid.mp3',
    ];
    debugPrint('Loaded ${_loadedMeditationAudios.length} meditation audios.');
  }

  /// Returns the audio path/URL for a given meditation ID.
  /// This is a placeholder; in a real app, you'd map IDs to actual URLs.
  static String? getAudioPath(String meditationId) {
    // This is a dummy implementation. You would need a proper mapping
    // or a way to construct the Cloudinary URL based on the meditationId.
    // For example, if meditationId is a Cloudinary public ID, you'd construct the URL.
    if (meditationId == 'meditation_1') {
      return _loadedMeditationAudios.isNotEmpty ? _loadedMeditationAudios[0] : null;
    } else if (meditationId == 'meditation_2') {
      return _loadedMeditationAudios.length > 1 ? _loadedMeditationAudios[1] : null;
    } else if (meditationId == 'meditation_3') {
      return _loadedMeditationAudios.length > 2 ? _loadedMeditationAudios[2] : null;
    }
    return null;
  }

  /// Plays an audio file from a given URL or path.
  /// Returns true if playback started successfully, false otherwise.
  static Future<bool> playAudio(String audioUrl) async {
    try {
      await _audioPlayer.play(UrlSource(audioUrl));
      debugPrint('Playing audio: $audioUrl');
      return true;
    } catch (e) {
      debugPrint('Error playing audio: $e');
      return false;
    }
  }

  /// Pauses the currently playing audio.
  static Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    debugPrint('Audio paused.');
  }

  /// Resumes the paused audio.
  static Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    debugPrint('Audio resumed.');
  }

  /// Stops the currently playing audio and releases resources.
  static Future<void> stopAudio() async {
    await _audioPlayer.stop();
    debugPrint('Audio stopped.');
  }

  /// Releases all resources held by the audio player.
  /// Call this when the audio player is no longer needed (e.g., on app exit).
  static Future<void> disposeAudioPlayer() async {
    await _audioPlayer.dispose();
    debugPrint('Audio player disposed.');
  }

  /// Returns the current playback position of the audio.
  static Future<Duration?> getCurrentPosition() async {
    return _audioPlayer.getCurrentPosition();
  }

  /// Returns the total duration of the current audio.
  static Future<Duration?> getDuration() async {
    return _audioPlayer.getDuration();
  }

  /// Seeks to a specific position in the audio.
  static Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Sets the volume of the audio player (0.0 to 1.0).
  static Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  /// Sets the playback speed (rate) of the audio (e.g., 1.0 for normal, 0.5 for half, 2.0 for double).
  static Future<void> setPlaybackRate(double rate) async {
    await _audioPlayer.setPlaybackRate(rate);
  }

  /// Stream of player state changes (playing, paused, stopped, completed).
  static Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  /// Stream of current position updates during playback.
  static Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  /// Stream of total duration updates.
  static Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  /// Stream that emits when the audio playback completes.
  static Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;
}
