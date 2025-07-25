// lib/core/providers/article_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:dhyana/core/services/article_content_service.dart'; // Import ArticleContentService
import 'package:dhyana/core/services/firestore_service.dart'; // Import FirestoreService (if articles are in Firestore)
import 'package:dhyana/models/article_model.dart'; // Import ArticleModel
import 'package:dhyana/providers/auth_provider.dart'; // To access firestoreServiceProvider

/// Provides an instance of [ArticleContentService].
/// This service needs to load its metadata, which can be done on app startup.
final articleContentServiceProvider = Provider<ArticleContentService>((ref) {
  final service = ArticleContentService();
  // Asynchronously load metadata when the service is first accessed.
  // This is a fire-and-forget, but for critical data, you might want
  // to await this in a splash screen or app initialization logic.
  service.loadArticlesMetadata();
  return service;
});

/// Provides a stream of all [ArticleModel]s.
///
/// This provider can be configured to fetch articles either from:
/// 1.  **Firestore:** If your articles are dynamically managed in Firestore.
///     (Uncomment the FirestoreService line and comment out the ArticleContentService line)
/// 2.  **Local Assets (via ArticleContentService):** If your articles are static Markdown files.
///     (Keep the ArticleContentService line uncommented)
///
/// For now, it will use `ArticleContentService` to fetch from local assets.
final articlesProvider = StreamProvider<List<ArticleModel>>((ref) {
  // Option 1: Fetch from Firestore (if articles are managed there)
  // final firestoreService = ref.watch(firestoreServiceProvider);
  // return firestoreService.getArticles();

  // Option 2: Fetch from local assets via ArticleContentService
  final articleContentService = ref.watch(articleContentServiceProvider);
  // Since ArticleContentService provides a List<ArticleModel> directly (not a stream),
  // we convert it to a Stream. This stream will emit once when data is loaded.
  return Stream.fromFuture(Future.value(articleContentService.getArticles()));
});

/// Provides the content (Markdown string) for a specific article ID.
/// This is a family provider, allowing you to get content for any article.
final articleContentProvider =
FutureProvider.family<String?, String>((ref, articleId) async {
  final articleContentService = ref.watch(articleContentServiceProvider);
  return await articleContentService.getArticleContent(articleId);
});
