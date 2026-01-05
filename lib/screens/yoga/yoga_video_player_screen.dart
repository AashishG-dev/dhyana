// lib/screens/yoga/yoga_video_player_screen.dart
import 'dart:async';
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YogaVideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String title;
  final String? taskType; // ✅ ADDED

  const YogaVideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    this.taskType, // ✅ ADDED
  });

  @override
  ConsumerState<YogaVideoPlayerScreen> createState() =>
      _YogaVideoPlayerScreenState();
}

class _YogaVideoPlayerScreenState extends ConsumerState<YogaVideoPlayerScreen> {
  late final YoutubePlayerController _controller;
  Timer? _progressTimer;
  int _playedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    // Timer to log progress every 15 seconds of playback
    _controller.addListener(() {
      if (_controller.value.playerState == PlayerState.playing &&
          _progressTimer == null) {
        _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _playedSeconds++;
        });
      } else if (_controller.value.playerState != PlayerState.playing) {
        _progressTimer?.cancel();
        _progressTimer = null;
      }
    });
  }

  void _logProgressAndCompleteTask() {
    if (_playedSeconds == 0) return;

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null) {
      final minutesPlayed = (_playedSeconds / 60).floor();

      if (widget.taskType == 'try_yoga') {
        ref.read(progressNotifierProvider.notifier).logYogaTime(userId, minutesPlayed);
        ref.read(taskCompletionServiceProvider).completeTask('try_yoga');
      } else if (widget.taskType == 'laugh_therapy') {
        ref.read(progressNotifierProvider.notifier).logLaughingTherapyTime(userId, minutesPlayed);
        ref.read(taskCompletionServiceProvider).completeTask('laugh_therapy');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.amber,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: CustomAppBar(
            title: widget.title,
            showBackButton: true,
          ),
          body: Center(
            child: player,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _logProgressAndCompleteTask(); // Log progress when leaving the screen
    _progressTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}