// lib/screens/stress_relief/stress_relief_suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/stress_relief_provider.dart'; // For stressReliefExercisesProvider
import 'package:dhyana/models/stress_relief_exercise_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

/// A screen that displays a list of stress relief suggestions/exercises.
/// Users can browse exercises by category or view all, and tap on them
/// to see a demo or more details. It integrates with `stressReliefExercisesProvider`
/// for fetching exercise metadata.
class StressReliefSuggestionsScreen extends ConsumerWidget {
  const StressReliefSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final stressReliefExercisesAsync = ref.watch(stressReliefExercisesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Stress Relief',
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
        child: Column(
          children: [
            // Optional: Category filter chips or search bar
            // Padding(
            //   padding: const EdgeInsets.all(AppConstants.paddingMedium),
            //   child: Wrap(
            //     spacing: AppConstants.paddingSmall,
            //     children: [
            //       FilterChip(label: Text('All'), onSelected: (b){}),
            //       FilterChip(label: Text('Breathing'), onSelected: (b){}),
            //       FilterChip(label: Text('Movement'), onSelected: (b){}),
            //     ],
            //   ),
            // ),
            Expanded(
              child: stressReliefExercisesAsync.when(
                data: (exercises) {
                  if (exercises.isEmpty) {
                    return Center(
                      child: Text(
                        'No stress relief exercises available at the moment.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return GestureDetector(
                        onTap: () {
                          context.go('/exercise-demo/${exercise.id}');
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.title,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingSmall),
                                Text(
                                  'Category: ${exercise.category}',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingSmall / 2),
                                Text(
                                  'Estimated Duration: ${exercise.estimatedDurationMinutes} minutes',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingSmall),
                                Text(
                                  exercise.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.8),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // You can add a demo video/GIF here if exercise.demoMediaUrl is available
                                if (exercise.demoMediaUrl != null && exercise.demoMediaUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                      child: Image.network(
                                        exercise.demoMediaUrl!,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 150,
                                          color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                                          child: Center(
                                            child: Icon(Icons.broken_image, size: 40, color: isDarkMode ? AppColors.textDark.withOpacity(0.5) : AppColors.textLight.withOpacity(0.5)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingWidget(message: 'Loading exercises...'),
                error: (e, st) => Center(
                  child: Text('Error loading exercises: $e',
                      style: TextStyle(color: AppColors.errorColor)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0), // Adjust index if this is a main tab
    );
  }
}
