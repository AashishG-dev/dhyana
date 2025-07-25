// lib/core/services/article_content_service.dart
import 'package:flutter/services.dart' show rootBundle; // For loading local assets
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:convert'; // For JSON decoding
import 'package:dhyana/models/article_model.dart'; // For ArticleModel

/// Manages local markdown articles and educational content,
/// including loading and parsing. This service is responsible for
/// fetching article metadata and the actual Markdown content.
class ArticleContentService {
  // A simple in-memory cache for article metadata and content.
  final Map<String, ArticleModel> _articleMetadataCache = {};
  final Map<String, String> _articleContentCache = {};

  /// Loads article metadata from a local JSON asset.
  /// In a real application, this metadata might come from Firestore,
  /// with the actual Markdown content stored as local assets or on Cloudinary.
  Future<void> loadArticlesMetadata() async {
    debugPrint('Loading articles metadata...');
    _articleMetadataCache.clear(); // Clear existing cache

    try {
      // Load article metadata from a local JSON file.
      // You would need to create this file, e.g., assets/data/articles_metadata.json
      final String response = await rootBundle.loadString('assets/data/articles_metadata.json');
      final List<dynamic> data = json.decode(response);

      for (var item in data) {
        final ArticleModel article = ArticleModel.fromJson(item, item['id']); // Assuming 'id' is present in JSON
        _articleMetadataCache[article.id!] = article;
      }
      debugPrint('Finished loading ${_articleMetadataCache.length} article metadata entries.');
    } catch (e) {
      debugPrint('Error loading articles metadata: $e');
      // If the file doesn't exist or is malformed, handle gracefully.
      // For a production app, you might want to fetch from Firestore as a fallback.
    }
  }

  /// Retrieves a list of all loaded article metadata.
  List<ArticleModel> getArticles() {
    return _articleMetadataCache.values.toList();
  }

  /// Retrieves the full Markdown content for a given article ID.
  /// It first checks the cache, and if not found, it loads from local assets.
  Future<String?> getArticleContent(String articleId) async {
    if (_articleContentCache.containsKey(articleId)) {
      debugPrint('Returning cached content for article: $articleId');
      return _articleContentCache[articleId];
    }

    debugPrint('Loading content for article: $articleId from assets...');
    try {
      // Assuming Markdown files are stored in assets/articles/
      // and named after their IDs (e.g., 'article_1.md').
      final String content = await rootBundle.loadString('assets/articles/$articleId.md');
      _articleContentCache[articleId] = content;
      debugPrint('Content loaded and cached for article: $articleId');
      return content;
    } catch (e) {
      debugPrint('Error loading content for article $articleId: $e');
      return null;
    }
  }

  /// Retrieves article metadata by its ID.
  ArticleModel? getArticleMetadata(String articleId) {
    return _articleMetadataCache[articleId];
  }

  /// Clears the in-memory caches.
  void clearCaches() {
    _articleMetadataCache.clear();
    _articleContentCache.clear();
    debugPrint('Article content caches cleared.');
  }
}
