// lib/screens/journal/journal_list_screen.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/journal_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/cards/journal_card.dart';
import 'package:dhyana/widgets/common/profile_avatar.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authUser = ref.watch(authStateProvider);
    final musicPlayerState = ref.watch(musicPlayerProvider);
    final shouldShowMiniPlayer = musicPlayerState.currentTrack != null &&
        (musicPlayerState.playerState == PlayerState.playing ||
            musicPlayerState.playerState == PlayerState.paused);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: '📖 My Journal',
          showBackButton: true,
          actions: [ProfileAvatar()],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.backgroundDark, const Color(0xFF1E1E1E)]
                  : [AppColors.backgroundLight, const Color(0xFFF9F9F9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: authUser.when(
            data: (user) {
              if (user == null) {
                return Center(
                  child: Text(
                    'Please log in to view your journal.',
                    style: AppTextStyles.bodyMedium,
                  ),
                );
              }

              final entriesAsync =
              ref.watch(userJournalEntriesProvider(user.uid));

              return entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No entries yet 📝',
                            style: AppTextStyles.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap the + button to start journaling!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: (isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight)
                                  .withAlpha(179),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // ✅ ADDED: Logic to separate and sort entries
                  final pinnedEntries =
                  entries.where((e) => e.isPinned).toList();
                  final unpinnedEntries =
                  entries.where((e) => !e.isPinned).toList();
                  // Pinned entries are not sorted by date, they stay in the order they were pinned
                  // Unpinned entries are sorted by date
                  unpinnedEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  final sortedEntries = [...pinnedEntries, ...unpinnedEntries];


                  // Calculate mood distribution
                  final moodCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
                  for (var entry in entries) {
                    moodCounts[entry.moodRating] =
                        (moodCounts[entry.moodRating] ?? 0) + 1;
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Recent Moods',
                                  style: AppTextStyles.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: moodCounts.entries.map((entry) {
                                    return Column(
                                      children: [
                                        Text(
                                          _getEmojiForMood(entry.key),
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.value.toString(),
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            top: AppConstants.paddingMedium,
                            left: AppConstants.paddingMedium,
                            right: AppConstants.paddingMedium,
                            bottom: shouldShowMiniPlayer
                                ? 80
                                : AppConstants.paddingMedium,
                          ),
                          itemCount: sortedEntries.length, // ✅ UPDATED: Use sorted list
                          itemBuilder: (_, i) {
                            final entry = sortedEntries[i]; // ✅ UPDATED: Use sorted list
                            return JournalCard(
                              entry: entry,
                              onTap: () => context.push('/journal-entry',
                                  extra: {
                                    'entryId': entry.id,
                                    'source': 'journal_list'
                                  }),
                              onEdit: () => context.push('/journal-entry',
                                  extra: {
                                    'entryId': entry.id,
                                    'source': 'journal_list'
                                  }),
                              onDelete: () async {
                                final confirm =
                                await Helpers.showConfirmationDialog(
                                  context,
                                  title: 'Delete Entry',
                                  message:
                                  'Are you sure you want to delete this?',
                                );
                                if (confirm == true && context.mounted) {
                                  await ref
                                      .read(journalNotifierProvider.notifier)
                                      .deleteJournalEntry(user.uid, entry.id!);
                                  if (context.mounted) {
                                    Helpers.showSnackbar(
                                        context, 'Entry deleted.');
                                  }
                                }
                              },
                              // ✅ ADDED: Handle the pin toggle action
                              onPinToggle: () async {
                                try {
                                  await ref
                                      .read(journalNotifierProvider.notifier)
                                      .togglePinStatus(user.uid, entry);
                                } catch (e) {
                                  if (context.mounted) {
                                    Helpers.showSnackbar(
                                        context, e.toString());
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LoadingWidget(
                    message: 'Loading journal entries...'),
                error: (e, st) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: AppColors.errorColor)),
                ),
              );
            },
            loading: () =>
            const LoadingWidget(message: 'Checking authentication...'),
            error: (e, st) => Center(
                child: Text('Auth error: $e',
                    style: const TextStyle(color: AppColors.errorColor))),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              context.push('/journal-entry', extra: {'source': 'journal_list'}),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowMiniPlayer) const MiniMusicPlayer(),
            const CustomBottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  String _getEmojiForMood(int moodRating) {
    switch (moodRating) {
      case 1:
        return '😔';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '🤔';
    }
  }
}