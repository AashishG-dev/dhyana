// lib/screens/stress_relief/stress_relief_suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/stress_relief_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/cards/exercise_card.dart';

class StressReliefSuggestionsScreen extends ConsumerWidget {
  const StressReliefSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final stressReliefExercisesAsync = ref.watch(stressReliefExercisesProvider);

    return Scaffold(
      appBar: const CustomAppBar(
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
        child: stressReliefExercisesAsync.when(
          data: (exercises) {
            if (exercises.isEmpty) {
              return Center(
                child: Text(
                  'No stress relief exercises available at the moment.',
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ExerciseCard(
                  exercise: exercise,
                  onTap: () {
                    context.go('/exercise-demo/${exercise.id}');
                  },
                );
              },
            );
          },
          loading: () => const LoadingWidget(message: 'Loading exercises...'),
          error: (e, st) => Center(
            child: Text('Error loading exercises: $e',
                style: const TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
