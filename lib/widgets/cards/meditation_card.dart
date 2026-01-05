import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/models/meditation_model.dart';

class MeditationCard extends StatelessWidget {
  final MeditationModel meditation;
  final VoidCallback? onTap;

  const MeditationCard({
    super.key,
    required this.meditation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.marginSmall),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meditation.imageUrl != null && meditation.imageUrl!.isNotEmpty)
              Image.network(
                meditation.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  child: Icon(Icons.self_improvement,
                      size: 40,
                      color: (isDark
                          ? AppColors.textDark
                          : AppColors.textLight)
                          .withOpacity(0.5)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    "${meditation.durationMinutes} min • ${meditation.category}",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: (isDark ? AppColors.textDark : AppColors.textLight)
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
