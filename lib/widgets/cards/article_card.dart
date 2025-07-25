// lib/widgets/cards/article_card.dart
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/models/article_model.dart'; // Import ArticleModel

/// A reusable card widget to display a summary of an article.
/// It features the article's title, category, reading time, and an optional image.
/// This card adheres to the Dhyana app's Glass Morphism theme.
class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback? onTap;

  /// Constructor for ArticleCard.
  const ArticleCard({
    super.key,
    required this.article,
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
                article.title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Category: ${article.category}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall / 2),
              Text(
                'By ${article.author} • ${article.readingTimeMinutes} min read',
                style: AppTextStyles.labelSmall.copyWith(
                  color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.6),
                ),
              ),
              // Optional: Display article image if available
              if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    child: Image.network(
                      article.imageUrl!,
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
