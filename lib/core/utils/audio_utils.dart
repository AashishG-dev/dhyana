// lib/core/utils/audio_utils.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// A utility class that wraps the audioplayers package to provide a simple,
/// static interface for controlling audio playback throughout the app.
class AudioUtils {
  /// Creates a new, configurable AudioPlayer instance.
  /// Giving each player a unique ID helps prevent conflicts and resource issues
  /// when multiple audio sources might be active (e.g., music and a meditation).
  static AudioPlayer createPlayer() {
    return AudioPlayer(playerId: UniqueKey().toString());
  }
}