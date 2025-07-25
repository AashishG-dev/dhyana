// lib/core/providers/meditation_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/core/services/meditation_audio_service.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/providers/auth_provider.dart';

final meditationsProvider = StreamProvider<Map<String, List<MeditationModel>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getMeditationSessions().map((meditations) {
    final Map<String, List<MeditationModel>> groupedMeditations = {};
    for (var meditation in meditations) {
      (groupedMeditations[meditation.category] ??= []).add(meditation);
    }
    return groupedMeditations;
  });
});

final meditationAudioServiceProvider = Provider<MeditationAudioService>((ref) {
  final cloudinaryService = ref.watch(cloudinaryServiceProvider);
  return MeditationAudioService(cloudinaryService);
});

class MeditationPlayerNotifier extends StateNotifier<AsyncValue<PlayerState>> {
  final MeditationAudioService _audioService;
  String? _currentMeditationId;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playerCompleteSubscription;

  MeditationPlayerNotifier(this._audioService) : super(const AsyncValue.data(PlayerState.stopped)) {
    _initListeners();
  }

  void _initListeners() {
    _playerStateSubscription = _audioService.onPlayerStateChanged.listen((playerState) {
      if (mounted) {
        state = AsyncValue.data(playerState);
      }
    });

    _playerCompleteSubscription = _audioService.onPlayerComplete.listen((_) {
      _currentMeditationId = null;
    });
  }

  /// ✅ FIX: This method now accepts the full MeditationModel.
  Future<void> playMeditation(MeditationModel meditation) async {
    state = const AsyncValue.loading();
    try {
      if (_currentMeditationId != meditation.id) {
        await _audioService.stopMeditation();
        _currentMeditationId = meditation.id;
        final bool started = await _audioService.playMeditation(meditation);
        if (!started) {
          throw Exception('Failed to start playback for meditation ID: ${meditation.id}');
        }
      } else {
        await _audioService.resumeMeditation();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pauseMeditation() async {
    try {
      await _audioService.pauseMeditation();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> stopMeditation() async {
    try {
      await _audioService.stopMeditation();
      _currentMeditationId = null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
    } catch (e) {
      debugPrint('Error seeking meditation: $e');
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

final meditationPlayerProvider =
StateNotifierProvider.autoDispose<MeditationPlayerNotifier, AsyncValue<PlayerState>>((ref) {
  final audioService = ref.watch(meditationAudioServiceProvider);
  ref.onDispose(() {
    audioService.stopMeditation();
  });
  return MeditationPlayerNotifier(audioService);
});

final currentMeditationPositionProvider = StreamProvider.autoDispose<Duration>((ref) {
  final audioService = ref.watch(meditationAudioServiceProvider);
  return audioService.onPositionChanged;
});

final currentMeditationDurationProvider = StreamProvider.autoDispose<Duration>((ref) {
  final audioService = ref.watch(meditationAudioServiceProvider);
  return audioService.onDurationChanged;
});

final meditationByIdProvider =
FutureProvider.family<MeditationModel?, String>((ref, meditationId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getMeditationById(meditationId);
});