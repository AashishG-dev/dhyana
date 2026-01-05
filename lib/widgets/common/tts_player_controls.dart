// lib/widgets/common/tts_player_controls.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/providers/tts_provider.dart';
import 'package:dhyana/widgets/common/tts_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TtsPlayerControls extends ConsumerWidget {
  final String? articleContent;
  final VoidCallback onClose;

  const TtsPlayerControls({
    required this.articleContent,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const TtsControls(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsPlayerState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);
    final ttsProgress = ref.watch(ttsProgressProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double progress = 0.0;
    if (ttsProgress != null &&
        articleContent != null &&
        articleContent!.isNotEmpty) {
      progress = ttsProgress.end / articleContent!.length;
    }

    return Material(
      color: isDark
          ? AppColors.backgroundDark.withOpacity(0.95)
          : AppColors.backgroundLight.withOpacity(0.95),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.glassBorderDark
                  : AppColors.glassBorderLight,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress.isNaN ? 0 : progress,
              backgroundColor: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => ttsNotifier.seekBackward(),
                  tooltip: 'Seek Backward',
                ),
                IconButton(
                  icon: Icon(
                    ttsPlayerState.ttsState == TtsState.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    if (articleContent != null) {
                      if (ttsPlayerState.ttsState == TtsState.playing) {
                        ttsNotifier.pause();
                      } else {
                        ttsNotifier.speak(articleContent!);
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => ttsNotifier.seekForward(),
                  tooltip: 'Seek Forward',
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showSettings(context),
                      tooltip: 'Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: onClose,
                      tooltip: 'Hide Player',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}