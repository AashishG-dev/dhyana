// lib/widgets/common/app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';

/// Wrapper widget that shows mini music player globally throughout the app
class AppWrapper extends ConsumerWidget {
  final Widget child;

  const AppWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicPlayerState = ref.watch(musicPlayerProvider);

    // Check if music is playing or paused (but loaded)
    final shouldShowMiniPlayer = musicPlayerState.currentTrack != null &&
        (musicPlayerState.playerState == PlayerState.playing ||
            musicPlayerState.playerState == PlayerState.paused);

    return Scaffold(
      // ✅ UPDATED: Using a Column to ensure content resizes correctly.
      body: Column(
        children: [
          // The main screen content (e.g., Home, Journal) will expand to fill available space.
          Expanded(child: child),
          // When the mini player appears, the Expanded widget above will shrink
          // to make room, preventing any overlap.
          if (shouldShowMiniPlayer) const MiniMusicPlayer(),
        ],
      ),
    );
  }
}