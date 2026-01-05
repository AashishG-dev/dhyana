// lib/providers/tts_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused }

@immutable
class TtsPlayerState {
  final TtsState ttsState;
  final double rate;
  final double pitch;
  final double volume;

  const TtsPlayerState({
    this.ttsState = TtsState.stopped,
    this.rate = 0.5,
    this.pitch = 1.0,
    this.volume = 0.75,
  });

  TtsPlayerState copyWith({
    TtsState? ttsState,
    double? rate,
    double? pitch,
    double? volume,
  }) {
    return TtsPlayerState(
      ttsState: ttsState ?? this.ttsState,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
    );
  }
}

class TtsNotifier extends StateNotifier<TtsPlayerState> {
  final FlutterTts _flutterTts;
  String _fullText = '';
  int _currentWordStart = 0;
  int _currentWordEnd = 0;

  final StreamController<({int start, int end})> _progressController =
  StreamController.broadcast();
  Stream<({int start, int end})> get onProgressChanged =>
      _progressController.stream;

  TtsNotifier()
      : _flutterTts = FlutterTts(),
        super(const TtsPlayerState()) {
    _flutterTts.setCompletionHandler(() {
      state = state.copyWith(ttsState: TtsState.stopped);
      _currentWordStart = 0;
      _currentWordEnd = 0;
      _progressController.add((start: 0, end: 0));
    });

    _flutterTts.setErrorHandler((msg) {
      state = state.copyWith(ttsState: TtsState.stopped);
    });

    _flutterTts.setProgressHandler((String text, int startOffset,
        int endOffset, String word) {
      _currentWordStart = startOffset;
      _currentWordEnd = endOffset;
      _progressController.add((start: startOffset, end: endOffset));
    });
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      _fullText = text;
      state = state.copyWith(ttsState: TtsState.playing);
      await _applyTtsSettings();
      await _flutterTts.speak(text.substring(_currentWordEnd));
    }
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    state = state.copyWith(ttsState: TtsState.paused);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _currentWordStart = 0;
    _currentWordEnd = 0;
    _progressController.add((start: 0, end: 0));
    state = state.copyWith(ttsState: TtsState.stopped);
  }

  Future<void> seekBackward() async {
    await _flutterTts.stop();
    final previousSentence =
    _fullText.substring(0, _currentWordStart).trim().lastIndexOf(' ');
    _currentWordEnd = previousSentence > 0 ? previousSentence : 0;
    await speak(_fullText);
  }

  Future<void> seekForward() async {
    await _flutterTts.stop();
    final nextSentence = _fullText.indexOf(' ', _currentWordEnd + 1);
    _currentWordEnd = nextSentence > 0 ? nextSentence : _fullText.length;
    await speak(_fullText);
  }

  Future<void> _applyTtsSettings() async {
    await _flutterTts.setVolume(state.volume);
    await _flutterTts.setSpeechRate(state.rate);
    await _flutterTts.setPitch(state.pitch);
  }

  Future<void> _updateAndRestartSpeech() async {
    if (state.ttsState == TtsState.playing) {
      await _flutterTts.stop();
      await speak(_fullText);
    }
  }

  Future<void> setRate(double rate) async {
    state = state.copyWith(rate: rate);
    await _updateAndRestartSpeech();
  }

  Future<void> setPitch(double pitch) async {
    state = state.copyWith(pitch: pitch);
    await _updateAndRestartSpeech();
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _updateAndRestartSpeech();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _progressController.close();
    super.dispose();
  }
}

final ttsProvider = StateNotifierProvider<TtsNotifier, TtsPlayerState>((ref) {
  return TtsNotifier();
});

final ttsProgressProvider = StreamProvider<({int start, int end})>((ref) {
  return ref.watch(ttsProvider.notifier).onProgressChanged;
});