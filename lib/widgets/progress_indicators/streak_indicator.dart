// lib/widgets/progress_indicators/streak_indicator.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';

/// A widget that displays a user's meditation streak (consecutive days of meditation).
/// It features a prominent number for the streak count and a descriptive label,
/// adhering to the Dhyana app's Glass Morphism theme.
class StreakIndicator extends StatelessWidget {
  final int streakCount;

  /// Constructor for StreakIndicator.
  const StreakIndicator({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      // Card provides the GlassContainer effect via AppTheme
      margin: const EdgeInsets.all(AppConstants.marginSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$streakCount',
              style: AppTextStyles.displaySmall.copyWith(
                color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall / 2),
            Text(
              'Day Streak',
              style: AppTextStyles.labelLarge.copyWith(
                color: isDarkMode ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
