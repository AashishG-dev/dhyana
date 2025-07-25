// lib/screens/articles/article_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/article_provider.dart'; // For articlesProvider
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

/// A screen that displays a list of available articles.
/// Users can browse articles and tap on them to view their full content.
/// It integrates with `articlesProvider` to fetch and display article metadata.
class ArticleListScreen extends ConsumerWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Articles',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: articlesAsync.when(
          data: (articles) {
            if (articles.isEmpty) {
              return Center(
                child: Text(
                  'No articles available at the moment.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return GestureDetector(
                  onTap: () {
                    context.go('/article-detail/${article.id}');
                  },
                  child: Card(
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
                          // You can add an image here if article.imageUrl is available
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
              },
            );
          },
          loading: () => const LoadingWidget(message: 'Loading articles...'),
          error: (e, st) => Center(
            child: Text('Error loading articles: $e',
                style: TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
      // ✅ FIX: Updated the currentIndex to 4 to highlight the new "Articles" tab.
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}