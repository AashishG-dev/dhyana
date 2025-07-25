// lib/widgets/cards/exercise_card.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/models/stress_relief_exercise_model.dart'; // Import StressReliefExerciseModel

/// A reusable card widget to display a summary of a stress relief exercise.
/// It features the exercise's title, category, estimated duration, and an optional demo image/GIF.
/// This card adheres to the Dhyana app's Glass Morphism theme.
class ExerciseCard extends StatelessWidget {
  final StressReliefExerciseModel exercise;
  final VoidCallback? onTap;

  /// Constructor for ExerciseCard.
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Card widget already provides the Glass Morphism styling via AppTheme
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
                'Estimated Duration: ${exercise.estimatedDurationMinutes} min',
                style: AppTextStyles.labelSmall.copyWith(
                  color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.6),
                ),
              ),
              // Optional: Display demo media image/GIF if available
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
  }
}
