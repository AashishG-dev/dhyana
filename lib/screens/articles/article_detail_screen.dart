// lib/screens/articles/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/article_provider.dart'; // For articleContentProvider
import 'package:dhyana/models/article_model.dart'; // For ArticleModel
import 'package:dhyana/core/utils/markdown_utils.dart'; // For Markdown rendering
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

/// A screen that displays the full content of a selected article.
/// It fetches the article's metadata and Markdown content using Riverpod
/// and renders the Markdown using `flutter_markdown`.
class ArticleDetailScreen extends ConsumerWidget {
  final String? articleId;

  /// Constructor for ArticleDetailScreen.
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (articleId == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Article Not Found',
          showBackButton: true,
        ),
        body: Center(
          child: Text(
            'Article ID is missing.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDarkMode ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
      );
    }

    // Watch the article content provider for the specific article ID
    final articleContentAsync = ref.watch(articleContentProvider(articleId!));
    // Also watch the articlesProvider to get metadata like title, author, etc.
    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Article',
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
        child: articleContentAsync.when(
          data: (markdownContent) {
            if (markdownContent == null || markdownContent.isEmpty) {
              return Center(
                child: Text(
                  'Article content not found.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              );
            }

            // Try to get article metadata for display
            ArticleModel? articleMetadata;
            articlesAsync.whenData((articles) {
              articleMetadata = articles.firstWhere(
                    (article) => article.id == articleId,
                orElse: () => ArticleModel(
                  id: articleId,
                  title: 'Unknown Article',
                  category: 'General',
                  readingTimeMinutes: 0,
                  author: 'Unknown',
                ),
              );
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    articleMetadata?.title ?? 'Loading Title...',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  if (articleMetadata != null)
                    Text(
                      'By ${articleMetadata!.author} • ${articleMetadata!.readingTimeMinutes} min read',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  // Render Markdown content using MarkdownUtils
                  MarkdownUtils.buildMarkdownBody(markdownContent, context),
                ],
              ),
            );
          },
          loading: () => const LoadingWidget(message: 'Loading article...'),
          error: (e, st) => Center(
            child: Text('Error loading article: $e',
                style: TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
    );
  }
}
