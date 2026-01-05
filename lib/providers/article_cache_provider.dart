// lib/providers/article_cache_provider.dart
import 'package:dhyana/core/services/image_cache_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/core/services/article_cache_service.dart';

class ArticleCacheNotifier extends StateNotifier<bool> {
  final ArticleCacheService _articleCacheService;
  final ImageCacheService _imageCacheService;
  final String _articleId;

  ArticleCacheNotifier(this._articleCacheService, this._imageCacheService, this._articleId)
      : super(false) {
    state = _articleCacheService.isArticleCached(_articleId);
  }

  Future<void> saveArticle({required String content, String? imageUrl}) async {
    await _articleCacheService.cacheArticleContent(_articleId, content);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _imageCacheService.preCacheImage(imageUrl);
    }
    state = true;
  }

  Future<void> removeArticle({String? imageUrl}) async {
    await _articleCacheService.removeArticleFromCache(_articleId);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _imageCacheService.removeImageFromCache(imageUrl);
    }
    state = false;
  }
}

// ✅ FIXED: The provider is now correctly structured to accept the family parameter (articleId)
// and read the other required services from the ref.
final articleCacheStateProvider =
StateNotifierProvider.family<ArticleCacheNotifier, bool, String>(
        (ref, articleId) {
      final articleCacheService = ref.watch(articleCacheServiceProvider);
      final imageCacheService = ref.watch(imageCacheServiceProvider);
      return ArticleCacheNotifier(articleCacheService, imageCacheService, articleId);
    });