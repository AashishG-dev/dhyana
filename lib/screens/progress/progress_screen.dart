// lib/screens/progress/progress_screen.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/core/utils/achievement_utils.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/widgets/cards/achievement_card.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/progress_indicators/streak_indicator.dart';
import 'package:dhyana/widgets/progress_indicators/progress_chart_widget.dart';
import 'package:dhyana/widgets/common/profile_avatar.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final authUser = ref.watch(authStateProvider);
    final musicPlayerState = ref.watch(musicPlayerProvider);
    final shouldShowMiniPlayer = musicPlayerState.currentTrack != null &&
        (musicPlayerState.playerState == PlayerState.playing ||
            musicPlayerState.playerState == PlayerState.paused);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'My Progress',
          showBackButton: true,
          actions: [ProfileAvatar()],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [AppColors.backgroundDark, const Color(0xFF212121)]
                  : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
            ),
          ),
          child: authUser.when(
            data: (user) {
              if (user == null) {
                return Center(
                  child: Text(
                    'Please log in to view your progress.',
                    style: AppTextStyles.bodyMedium,
                  ),
                );
              }

              final progressDataAsync = ref.watch(userProgressDataProvider(user.uid));

              return progressDataAsync.when(
                data: (progressData) {
                  if (progressData == null) {
                    return Center(
                      child: Text(
                        'No progress data available yet. Start your journey!',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final unlockedAchievements = AchievementUtils.checkAchievements(progressData);

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: AppConstants.paddingMedium,
                      left: AppConstants.paddingMedium,
                      right: AppConstants.paddingMedium,
                      bottom: shouldShowMiniPlayer ? 80 : AppConstants.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Journey So Far',
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                margin: const EdgeInsets.only(right: AppConstants.marginSmall),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${progressData.totalMeditationMinutes}',
                                        style: AppTextStyles.displaySmall.copyWith(
                                          color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                                        ),
                                      ),
                                      const SizedBox(height: AppConstants.paddingSmall / 2),
                                      Text(
                                        'Total Min. Meditated',
                                        style: AppTextStyles.labelLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: StreakIndicator(streakCount: progressData.meditationStreak),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Card(
                          margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            child: Column(
                              children: [
                                Text(
                                  '${progressData.totalJournalEntries}',
                                  style: AppTextStyles.displaySmall.copyWith(
                                    color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingSmall / 2),
                                Text(
                                  'Journal Entries',
                                  style: AppTextStyles.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        Text(
                          'Mood Trend',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        ProgressChartWidget(
                          chartTitle: 'Daily Mood Ratings',
                          yAxisLabel: 'Mood (1-5)',
                          data: progressData.moodRatingsByDay,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),

                        Text(
                          'Achievements',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        if (unlockedAchievements.isEmpty)
                          const Center(
                            child: Text('Keep up your practice to unlock new badges!'),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: unlockedAchievements.length,
                            itemBuilder: (context, index) {
                              return AchievementCard(achievement: unlockedAchievements[index]);
                            },
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const LoadingWidget(message: 'Loading your progress...'),
                error: (e, st) => Center(
                  child: Text('Error loading progress: $e',
                      style: const TextStyle(color: AppColors.errorColor)),
                ),
              );
            },
            loading: () => const LoadingWidget(message: 'Checking authentication...'),
            error: (e, st) => Center(
              child: Text('Authentication error: $e',
                  style: const TextStyle(color: AppColors.errorColor)),
            ),
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowMiniPlayer) const MiniMusicPlayer(),
            const CustomBottomNavBar(currentIndex: 4),
          ],
        ),
      ),
    );
  }
}