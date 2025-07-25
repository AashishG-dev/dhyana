// lib/screens/progress/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/auth_provider.dart'; // For authStateProvider
import 'package:dhyana/providers/user_profile_provider.dart'; // For currentUserProfileProvider
import 'package:dhyana/providers/progress_provider.dart'; // For userProgressDataProvider
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/progress_indicators/streak_indicator.dart';
import 'package:dhyana/widgets/progress_indicators/progress_chart_widget.dart';

/// A screen that displays the user's overall progress in the Dhyana app.
/// It includes aggregated statistics like total meditation minutes,
/// meditation streak, and potentially charts for mood trends or meditation duration.
/// It integrates with `userProgressDataProvider` to display real-time progress.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final authUser = ref.watch(authStateProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Progress',
        showBackButton: true,
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
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
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Journey So Far',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // --- Key Metrics ---
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.paddingSmall / 2),
                                    Text(
                                      'Total Min. Meditated',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                                      ),
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingSmall / 2),
                              Text(
                                'Journal Entries',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // --- Mood Trend Chart ---
                      Text(
                        'Mood Trend',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ProgressChartWidget(
                        chartTitle: 'Daily Mood Ratings',
                        yAxisLabel: 'Mood (1-5)',
                        data: progressData.moodRatingsByDay,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // You can add more charts or progress indicators here
                      // e.g., 'Meditation Duration Trend', 'Stress Level Over Time'
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'Loading your progress...'),
              error: (e, st) => Center(
                child: Text('Error loading progress: $e',
                    style: TextStyle(color: AppColors.errorColor)),
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Checking authentication...'),
          error: (e, st) => Center(
            child: Text('Authentication error: $e',
                style: TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0), // Adjust index if this is a main tab
    );
  }
}
