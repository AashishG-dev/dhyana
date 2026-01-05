// lib/screens/articles/article_list_screen.dart
import 'package:dhyana/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

class ArticleListScreen extends ConsumerWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Articles',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
            colors: [AppColors.backgroundDark, const Color(0xFF2C2C2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              AppColors.backgroundLight,
              const Color(0xFFF0F0F0)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: articlesAsync.when(
          data: (groupedArticles) {
            final allArticles =
            groupedArticles.values.expand((list) => list).toList();

            if (allArticles.isEmpty) {
              return Center(
                child: Text(
                  'No articles available at the moment.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                    isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: allArticles.length,
              itemBuilder: (context, index) {
                final article = allArticles[index];
                return _buildArticleCard(context, article);
              },
            );
          },
          loading: () => const LoadingWidget(message: 'Loading articles...'),
          error: (e, st) => Center(
            child: Text(
              'Error loading articles: $e',
              style: const TextStyle(color: AppColors.errorColor),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel article) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/article-detail/${article.id}');
        },
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                article.imageUrl ?? "https://placehold.co/600x400?text=Read",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
              Positioned(
                bottom: AppConstants.paddingMedium,
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall / 2),
                    Text(
                      article.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            blurRadius: 4.0,
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}