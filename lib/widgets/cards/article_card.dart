// lib/widgets/cards/article_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback? onTap;
  final VoidCallback? onUnsavePressed;
  final CacheManager? cacheManager;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onUnsavePressed,
    this.cacheManager,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Let the column size itself naturally
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0), // Space for the icon
                    child: Text(
                      article.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                  if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        child: CachedNetworkImage(
                          cacheManager: cacheManager,
                          imageUrl: article.imageUrl!,
                          height: 120, // Reduced height to fix overflow
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                            child: Icon(Icons.broken_image,
                                size: 40,
                                color: (isDarkMode ? AppColors.textDark : AppColors.textLight)
                                    .withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (onUnsavePressed != null)
                Positioned(
                  top: -12,
                  right: -12,
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_rounded),
                    color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                    tooltip: 'Remove from Saved',
                    onPressed: onUnsavePressed,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}