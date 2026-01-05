// lib/providers/music_provider.dart
import 'dart:async';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/models/music_track_model.dart';
import 'package:dhyana/core/services/jamendo_service.dart';
import 'package:dhyana/core/services/music_audio_service.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/providers/auth_provider.dart';

enum RepeatMode { off, all, one }

final jamendoServiceProvider = Provider((ref) => JamendoService());

final jamendoMusicProvider = FutureProvider.family<List<MusicTrackModel>, ({String query, int limit})>((ref, params) {
  final jamendoService = ref.watch(jamendoServiceProvider);
  return jamendoService.searchMusic(query: params.query, limit: params.limit);
});

// Provider to hold the current search query
final musicSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider to fetch search results based on the query
final musicSearchResultsProvider = FutureProvider.family<List<MusicTrackModel>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final jamendoService = ref.watch(jamendoServiceProvider);
  return jamendoService.searchMusic(query: query, limit: 50);
});


final musicAudioServiceProvider = Provider((ref) {
  final service = MusicAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

@immutable
class MusicPlayerState {
  final PlayerState playerState;
  final MusicTrackModel? currentTrack;
  final List<MusicTrackModel> currentPlaylist;
  final RepeatMode repeatMode;
  final bool isLoading;
  final bool isBuffering;

  const MusicPlayerState({
    this.playerState = PlayerState.stopped,
    this.currentTrack,
    this.currentPlaylist = const [],
    this.repeatMode = RepeatMode.off,
    this.isLoading = false,
    this.isBuffering = false,
  });

  MusicPlayerState copyWith({
    PlayerState? playerState,
    MusicTrackModel? currentTrack,
    List<MusicTrackModel>? currentPlaylist,
    RepeatMode? repeatMode,
    bool? isLoading,
    bool? isBuffering,
  }) {
    return MusicPlayerState(
      playerState: playerState ?? this.playerState,
      currentTrack: currentTrack ?? this.currentTrack,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      repeatMode: repeatMode ?? this.repeatMode,
      isLoading: isLoading ?? this.isLoading,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

class MusicPlayerNotifier extends StateNotifier<MusicPlayerState> {
  final MusicAudioService _audioService;
  final Ref _ref;
  final Stopwatch _stopwatch = Stopwatch();
  StreamSubscription<ja.PlayerState>? _playerStateSubscription;
  int _currentIndex = -1;

  MusicPlayerNotifier(this._audioService, this._ref) : super(const MusicPlayerState()) {
    _playerStateSubscription = _audioService.onPlayerStateChanged.listen((playerStatus) {
      if (mounted) {
        final newPlayerState = _mapPlayerState(playerStatus);
        final isBufferingState = playerStatus.processingState == ja.ProcessingState.buffering ||
            playerStatus.processingState == ja.ProcessingState.loading;

        state = state.copyWith(
            playerState: newPlayerState,
            isBuffering: isBufferingState
        );

        if (playerStatus.processingState == ja.ProcessingState.completed) {
          _handleSongCompletion();
        }
      }
    }, onError: (error) {
      debugPrint('Player state stream error: $error');
    });
  }

  PlayerState _mapPlayerState(ja.PlayerState playerState) {
    switch (playerState.processingState) {
      case ja.ProcessingState.idle:
        return PlayerState.stopped;
      case ja.ProcessingState.loading:
      case ja.ProcessingState.buffering:
        return playerState.playing ? PlayerState.playing : PlayerState.paused;
      case ja.ProcessingState.ready:
        return playerState.playing ? PlayerState.playing : PlayerState.paused;
      case ja.ProcessingState.completed:
        return PlayerState.completed;
    }
  }

  void _handleSongCompletion() {
    _logMusicTime();
    if (state.repeatMode == RepeatMode.one) {
      if (state.currentPlaylist.isNotEmpty) {
        play(state.currentPlaylist[_currentIndex], state.currentPlaylist);
      }
    } else if (state.repeatMode == RepeatMode.all) {
      playNext();
    } else {
      if (_currentIndex < state.currentPlaylist.length - 1) {
        playNext();
      } else {
        stop();
      }
    }
  }

  Future<void> play(MusicTrackModel track, List<MusicTrackModel> playlist) async {
    try {
      if (state.currentTrack?.id == track.id && state.playerState == PlayerState.paused) {
        await _audioService.resumeMusic();
        _stopwatch.start();
        return;
      }

      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _logMusicTime();
      }

      state = state.copyWith(
          isLoading: true,
          isBuffering: true,
          currentPlaylist: playlist,
          currentTrack: track
      );

      _currentIndex = playlist.indexWhere((t) => t.id == track.id);

      await _audioService.setLoopMode(state.repeatMode == RepeatMode.one);
      final success = await _audioService.playMusic(track);

      if (success) {
        _stopwatch.reset();
        _stopwatch.start();
        state = state.copyWith(
          isLoading: false,
          playerState: PlayerState.playing,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isBuffering: false,
          playerState: PlayerState.stopped,
        );
        debugPrint('Failed to play track: ${track.title}');
      }
    } catch (e) {
      debugPrint('Error in play method: $e');
      state = state.copyWith(
        isLoading: false,
        isBuffering: false,
        playerState: PlayerState.stopped,
      );
    }
  }

  void _logMusicTime() {
    final userId = _ref.read(authStateProvider).value?.uid;
    if (userId != null && _stopwatch.elapsed.inSeconds > 0) {
      _ref.read(progressNotifierProvider.notifier).logMusicTime(userId, _stopwatch.elapsed.inSeconds);
    }
    _stopwatch.reset();
  }

  Future<void> pause() async {
    try {
      await _audioService.pauseMusic();
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _logMusicTime();
      }
      if (mounted) {
        state = state.copyWith(playerState: PlayerState.paused);
      }
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _audioService.resumeMusic();
      if (!_stopwatch.isRunning && state.currentTrack != null) {
        _stopwatch.start();
      }
      if (mounted) {
        state = state.copyWith(playerState: PlayerState.playing);
      }
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioService.stopMusic();
      _stopwatch.stop();
      _logMusicTime();
      state = state.copyWith(
          currentTrack: null,
          playerState: PlayerState.stopped,
          currentPlaylist: []
      );
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  void closePlayer() {
    try {
      _audioService.stopMusic();
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _logMusicTime();
      }
      state = const MusicPlayerState();
    } catch (e) {
      debugPrint('Error closing player: $e');
    }
  }

  Future<void> playNext() async {
    if (state.currentPlaylist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % state.currentPlaylist.length;
    await play(state.currentPlaylist[_currentIndex], state.currentPlaylist);
  }

  Future<void> playPrevious() async {
    if (state.currentPlaylist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + state.currentPlaylist.length) % state.currentPlaylist.length;
    await play(state.currentPlaylist[_currentIndex], state.currentPlaylist);
  }

  Future<void> togglePlayPause() async {
    if (state.playerState == PlayerState.playing) {
      await pause();
    } else if (state.playerState == PlayerState.paused && state.currentTrack != null) {
      await resume();
    } else if (state.currentTrack != null) {
      await play(state.currentTrack!, state.currentPlaylist);
    }
  }

  Future<void> toggleRepeatMode() async {
    try {
      final nextMode = RepeatMode.values[(state.repeatMode.index + 1) % RepeatMode.values.length];
      await _audioService.setLoopMode(nextMode == RepeatMode.one);
      state = state.copyWith(repeatMode: nextMode);
    } catch (e) {
      debugPrint('Error toggling repeat mode: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _logMusicTime();
    }
    super.dispose();
  }
}

final musicPlayerProvider = StateNotifierProvider<MusicPlayerNotifier, MusicPlayerState>((ref) {
  final audioService = ref.watch(musicAudioServiceProvider);
  return MusicPlayerNotifier(audioService, ref);
});

final currentMusicPositionProvider = StreamProvider<Duration>((ref) {
  ref.watch(musicPlayerProvider);
  return ref.watch(musicAudioServiceProvider).onPositionChanged;
});

final currentMusicDurationProvider = StreamProvider<Duration?>((ref) {
  ref.watch(musicPlayerProvider);
  return ref.watch(musicAudioServiceProvider).onDurationChanged;
});