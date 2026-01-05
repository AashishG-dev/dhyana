// lib/widgets/common/mini_music_player.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhyana/models/music_track_model.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:go_router/go_router.dart';

class MiniMusicPlayer extends ConsumerWidget {
  const MiniMusicPlayer({super.key});

  // Helper widget to determine which image to show
  Widget _buildPlayerImage(MusicTrackModel track) {
    // Prioritize local image if it exists
    if (track.localImagePath != null && track.localImagePath!.isNotEmpty) {
      final file = File(track.localImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        );
      }
    }
    // Fallback to network image
    if (track.imageUrl != null && track.imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: track.imageUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) => _buildImagePlaceholder(),
      );
    }
    // Default placeholder
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 40,
      height: 40,
      color: Colors.grey.withAlpha(77),
      child: const Icon(Icons.music_note, size: 20, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final musicPlayerState = ref.watch(musicPlayerProvider);
    final musicPlayerNotifier = ref.read(musicPlayerProvider.notifier);
    final currentTrack = musicPlayerState.currentTrack;
    final playerState = musicPlayerState.playerState;

    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        context.push('/music-player', extra: {
          'track': currentTrack,
          'playlist': musicPlayerState.currentPlaylist,
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassDarkSurface : AppColors.glassLightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildPlayerImage(currentTrack),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentTrack.title,
                    style: TextStyle(
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    currentTrack.artist,
                    style: TextStyle(
                      color: (isDark ? AppColors.textDark : AppColors.textLight).withAlpha(179),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 22),
              onPressed: () => musicPlayerNotifier.playPrevious(),
            ),
            IconButton(
              icon: Icon(
                playerState == PlayerState.playing
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: isDark
                    ? AppColors.primaryLightGreen
                    : AppColors.primaryLightBlue,
                size: 32,
              ),
              onPressed: () {
                if (playerState == PlayerState.playing) {
                  musicPlayerNotifier.pause();
                } else {
                  musicPlayerNotifier.play(currentTrack, musicPlayerState.currentPlaylist);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 22),
              onPressed: () => musicPlayerNotifier.playNext(),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 22,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                musicPlayerNotifier.closePlayer();
              },
            ),
          ],
        ),
      ),
    );
  }
}