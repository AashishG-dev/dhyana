import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/models/stress_relief_exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  final StressReliefExerciseModel exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.title,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Category: ${exercise.category} • ${exercise.estimatedDurationMinutes} min',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                exercise.description,
                style: AppTextStyles.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
