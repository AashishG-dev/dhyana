// lib/screens/articles/saved_articles_screen.dart
import 'package:dhyana/core/services/image_cache_service.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/providers/article_cache_provider.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/cards/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SavedArticlesScreen extends ConsumerWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedArticlesAsync = ref.watch(cachedArticlesProvider);
    final customCacheManager = ref.watch(customCacheManagerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Saved Articles',
        showBackButton: true,
      ),
      body: savedArticlesAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Articles you save for offline reading will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(cachedArticlesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(
                  article: article,
                  cacheManager: customCacheManager, // Pass the cache manager for the image
                  onTap: () => context.push('/article-detail/${article.id}'),
                  onUnsavePressed: () async { // Logic to unsave the article
                    final notifier = ref.read(articleCacheStateProvider(article.id!).notifier);
                    await notifier.removeArticle(imageUrl: article.imageUrl);
                    ref.invalidate(cachedArticlesProvider); // Invalidate to refresh the list
                    if (context.mounted) {
                      Helpers.showSnackbar(context, 'Article removed from saved items.');
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading saved articles...'),
        error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }
}