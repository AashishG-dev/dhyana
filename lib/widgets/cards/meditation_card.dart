// lib/widgets/cards/meditation_card.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/models/meditation_model.dart'; // Import MeditationModel

/// A reusable card widget to display a summary of a meditation session.
/// It features the meditation's title, category, duration, and an optional image.
/// This card adheres to the Dhyana app's Glass Morphism theme.
class MeditationCard extends StatelessWidget {
  final MeditationModel meditation;
  final VoidCallback? onTap;

  /// Constructor for MeditationCard.
  const MeditationCard({
    super.key,
    required this.meditation,
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
                meditation.title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Category: ${meditation.category}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall / 2),
              Text(
                'Duration: ${meditation.durationMinutes} min',
                style: AppTextStyles.labelSmall.copyWith(
                  color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.6),
                ),
              ),
              // Optional: Display meditation image if available
              if (meditation.imageUrl != null && meditation.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    child: Image.network(
                      meditation.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                        child: Center(
                          child: Icon(Icons.self_improvement, size: 40, color: isDarkMode ? AppColors.textDark.withOpacity(0.5) : AppColors.textLight.withOpacity(0.5)),
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
