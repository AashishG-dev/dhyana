// lib/widgets/progress_indicators/streak_indicator.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';

class StreakIndicator extends StatelessWidget {
  final int streakCount;

  const StreakIndicator({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(AppConstants.marginSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$streakCount',
              style: AppTextStyles.displayLarge.copyWith(
                color: isDark
                    ? AppColors.primaryLightGreen
                    : AppColors.primaryLightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Day Streak',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
