// lib/core/services/music_audio_service.dart
import 'package:just_audio/just_audio.dart' as ja;
import 'package:dhyana/models/music_track_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class MusicAudioService {
  final ja.AudioPlayer _audioPlayer;

  MusicAudioService() : _audioPlayer = ja.AudioPlayer() {
    debugPrint('MusicAudioService initialized');
  }

  Future<void> preloadMusic(MusicTrackModel track) async {
    if (track.audioUrl.isNotEmpty) {
      try {
        debugPrint('Preloading: ${track.title}');
        ja.AudioSource audioSource;

        if (track.audioUrl.startsWith('http')) {
          audioSource = ja.AudioSource.uri(
            Uri.parse(track.audioUrl),
            headers: {
              'User-Agent': 'DhyanaApp/1.0',
            },
          );
        } else {
          final file = File(track.audioUrl);
          if (await file.exists()) {
            audioSource = ja.AudioSource.file(file.path);
          } else {
            debugPrint('Preload failed: Local file not found at ${file.path}');
            return;
          }
        }

        await _audioPlayer.setAudioSource(audioSource);
        await _audioPlayer.stop();
        debugPrint('Successfully preloaded: ${track.title}');
      } catch (e) {
        debugPrint('Error preloading audio for ${track.title}: $e');
      }
    } else {
      debugPrint('Cannot preload: Empty audio URL for ${track.title}');
    }
  }

  Future<bool> playMusic(MusicTrackModel track) async {
    if (track.audioUrl.isEmpty) {
      debugPrint('Cannot play music track: audio URL is empty for ${track.id}');
      return false;
    }

    try {
      debugPrint('Attempting to play: ${track.title} from ${track.audioUrl}');

      ja.AudioSource audioSource;

      if (track.audioUrl.startsWith('http')) {
        debugPrint('Playing remote file: ${track.audioUrl}');
        audioSource = ja.AudioSource.uri(
          Uri.parse(track.audioUrl),
          headers: {
            'User-Agent': 'DhyanaApp/1.0',
            'Accept': 'audio/*',
          },
        );
      } else {
        debugPrint('Playing local file: ${track.audioUrl}');
        final file = File(track.audioUrl);

        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint('Local file exists, size: ${fileSize} bytes');
          audioSource = ja.AudioSource.file(file.path);
        } else {
          debugPrint('Cannot play music track: Local file not found at ${file.path}');
          return false;
        }
      }

      await _audioPlayer.setAudioSource(audioSource);

      await _audioPlayer.play();

      debugPrint('Successfully started playing: ${track.title}');
      return true;

    } catch (e) {
      debugPrint('Error playing music ${track.title}: $e');

      try {
        await _audioPlayer.stop();
      } catch (stopError) {
        debugPrint('Error stopping after play failure: $stopError');
      }

      return false;
    }
  }

  Future<void> pauseMusic() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        debugPrint('Music paused successfully');
      } else {
        debugPrint('Music was not playing, pause ignored');
      }
    } catch (e) {
      debugPrint('Error pausing music: $e');
      throw e;
    }
  }

  Future<void> resumeMusic() async {
    try {
      if (!_audioPlayer.playing && _audioPlayer.processingState != ja.ProcessingState.idle) {
        await _audioPlayer.play();
        debugPrint('Music resumed successfully');
      } else {
        debugPrint('Cannot resume: Player state is ${_audioPlayer.processingState}');
      }
    } catch (e) {
      debugPrint('Error resuming music: $e');
      throw e;
    }
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
      debugPrint('Music stopped successfully');
    } catch (e) {
      debugPrint('Error stopping music: $e');
      throw e;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      final duration = _audioPlayer.duration;
      if (duration != null && position <= duration) {
        await _audioPlayer.seek(position);
        debugPrint('Seeked to position: ${position.toString()}');
      } else {
        debugPrint('Cannot seek to position: ${position.toString()}, duration: ${duration.toString()}');
      }
    } catch (e) {
      debugPrint('Error seeking to position ${position.toString()}: $e');
      throw e;
    }
  }

  Future<void> setLoopMode(bool isLooping) async {
    try {
      await _audioPlayer.setLoopMode(isLooping ? ja.LoopMode.one : ja.LoopMode.off);
      debugPrint('Loop mode set to: ${isLooping ? 'one' : 'off'}');
    } catch (e) {
      debugPrint('Error setting loop mode: $e');
      throw e;
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      debugPrint('Volume set to: $clampedVolume');
    } catch (e) {
      debugPrint('Error setting volume: $e');
      throw e;
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.1, 3.0);
      await _audioPlayer.setSpeed(clampedSpeed);
      debugPrint('Speed set to: $clampedSpeed');
    } catch (e) {
      debugPrint('Error setting speed: $e');
      throw e;
    }
  }

  bool get isPlaying => _audioPlayer.playing;

  ja.ProcessingState get processingState => _audioPlayer.processingState;

  Duration? get duration => _audioPlayer.duration;

  Duration get position => _audioPlayer.position;

  double get volume => _audioPlayer.volume;

  double get speed => _audioPlayer.speed;

  Stream<ja.PlayerState> get onPlayerStateChanged =>
      _audioPlayer.playerStateStream.handleError((error) {
        debugPrint('Player state stream error: $error');
      });

  Stream<Duration> get onPositionChanged =>
      _audioPlayer.positionStream.handleError((error) {
        debugPrint('Position stream error: $error');
      });

  Stream<Duration?> get onDurationChanged =>
      _audioPlayer.durationStream.handleError((error) {
        debugPrint('Duration stream error: $error');
      });

  Stream<double> get onVolumeChanged =>
      _audioPlayer.volumeStream.handleError((error) {
        debugPrint('Volume stream error: $error');
      });

  Stream<double> get onSpeedChanged =>
      _audioPlayer.speedStream.handleError((error) {
        debugPrint('Speed stream error: $error');
      });

  void dispose() {
    try {
      debugPrint('Disposing MusicAudioService...');

      _audioPlayer.stop().catchError((error) {
        debugPrint('Error stopping player during dispose: $error');
      });

      _audioPlayer.dispose();

      debugPrint('MusicAudioService disposed successfully');
    } catch (e) {
      debugPrint('Error disposing MusicAudioService: $e');
    }
  }

  Future<bool> canPlayFile(String filePath) async {
    try {
      if (filePath.startsWith('http')) {
        return true;
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          return false;
        }

        final extension = filePath.toLowerCase().split('.').last;
        final supportedExtensions = ['mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg'];
        return supportedExtensions.contains(extension);
      }
    } catch (e) {
      debugPrint('Error checking if file is playable: $e');
      return false;
    }
  }

  String getAudioFormat(String audioUrl) {
    try {
      if (audioUrl.startsWith('http')) {
        final uri = Uri.parse(audioUrl);
        final path = uri.path;
        final extension = path.split('.').last.toLowerCase();
        return extension.isNotEmpty ? extension : 'unknown';
      } else {
        final extension = audioUrl.split('.').last.toLowerCase();
        return extension.isNotEmpty ? extension : 'unknown';
      }
    } catch (e) {
      debugPrint('Error getting audio format: $e');
      return 'unknown';
    }
  }
}