import 'package:dhyana/models/music_track_model.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/widgets/cards/music_track_card.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';

class MusicCategoryScreen extends ConsumerWidget {
  final String categoryTitle;
  final String categoryQuery;

  const MusicCategoryScreen({
    required this.categoryTitle,
    required this.categoryQuery,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicTracksAsync = ref.watch(jamendoMusicProvider(
        (query: categoryQuery, limit: 50)
    ));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: categoryTitle, showBackButton: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: musicTracksAsync.when(
                data: (tracks) {
                  if (tracks.isEmpty) {
                    return const Center(child: Text('No music found for this category.'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return MusicTrackCard(
                        track: track,
                        onTap: () => context.push('/music-player', extra: {
                          'track': track,
                          'playlist': tracks,
                        }),
                      );
                    },
                  );
                },
                loading: () => const LoadingWidget(message: 'Loading Music...'),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
            const MiniMusicPlayer(),
          ],
        ),
      ),
    );
  }
}
