// lib/providers/article_provider.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/models/quote_model.dart';
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/core/services/article_cache_service.dart';
import 'package:dhyana/core/services/api_service.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'dart:convert';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final articlesProvider = StreamProvider<Map<String, List<ArticleModel>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // Fetch articles and group them by category
  return firestoreService.getArticles().map((articles) {
    final Map<String, List<ArticleModel>> groupedArticles = {};
    for (var article in articles) {
      (groupedArticles[article.category] ??= []).add(article);
    }
    return groupedArticles;
  });
});

// CORRECTED LOGIC: This provider no longer automatically caches articles.
// It only reads from the cache or fetches from Firestore. Caching is now an explicit user action.
final articleContentProvider = FutureProvider.family<String?, String>((ref, articleId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final cacheService = ref.watch(articleCacheServiceProvider);

  // 1. Try to get the content from the local cache first.
  String? content = await cacheService.getCachedArticleContent(articleId);

  // 2. If it's not in the cache, fetch from Firestore.
  //    (But do NOT write it back to the cache here.)
  content ??= await firestoreService.getArticleContent(articleId);

  return content;
});

final cachedArticlesProvider = FutureProvider<List<ArticleModel>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final cacheService = ref.watch(articleCacheServiceProvider);

  final cachedIds = cacheService.getCachedArticleIds();
  final List<ArticleModel> articles = [];

  for (final id in cachedIds) {
    final article = await firestoreService.getArticleById(id);
    if (article != null) {
      articles.add(article);
    }
  }

  return articles;
});

final quoteOfTheDayProvider = FutureProvider<QuoteModel?>((ref) async {
  try {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
    if (response.statusCode == 200) {
      return QuoteModel.fromJson(response.body);
    } else {
      return null;
    }
  } catch (e) {
    debugPrint('Failed to load quote: $e');
    return null;
  }
});


// State for our Mindful Moment feature
enum MindfulMomentState { initial, loading, data, error }

class MindfulMoment {
  final String content;
  final MindfulMomentState state;

  MindfulMoment({required this.content, this.state = MindfulMomentState.initial});
}

// Notifier to fetch content from Gemini
class MindfulMomentNotifier extends StateNotifier<MindfulMoment> {
  final ApiService _apiService;

  MindfulMomentNotifier(this._apiService) : super(MindfulMoment(content: ''));

  Future<void> fetchMoment(String category) async {
    state = MindfulMoment(content: '', state: MindfulMomentState.loading);
    try {
      final prompt = _getPromptForCategory(category);
      final response = await _apiService.post(
        'v1beta/models/gemini-1.5-flash:generateContent',
        {
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ]
        },
        headers: {
          'X-goog-api-key': AppConstants.geminiApiKey,
        },
        baseUrl: AppConstants.geminiApiBaseUrl,
      );

      final content = response['candidates'][0]['content']['parts'][0]['text'];
      state = MindfulMoment(content: content, state: MindfulMomentState.data);
    } catch (e) {
      state = MindfulMoment(content: 'Sorry, I couldn\'t fetch a moment for you. Please try again.', state: MindfulMomentState.error);
    }
  }

  String _getPromptForCategory(String category) {
    switch (category) {
      case 'Affirmation':
        return 'Generate a short, powerful, and positive affirmation for mindfulness and self-love. Make it one or two sentences.';
      case 'Short Story':
        return 'Write a very short, uplifting story (less than 150 words) with a moral about mindfulness, peace, or kindness.';
      case 'Mindful Joke':
        return 'Tell me a light-hearted, clean joke or pun related to mindfulness, meditation, or relaxation.';
      case 'Today\'s Fact':
        return 'Give me an interesting, fun, and brief fact about psychology, the human brain, or the benefits of mindfulness.';
      default:
        return 'Generate a short, inspiring quote about life.';
    }
  }

  void clearMoment() {
    state = MindfulMoment(content: '', state: MindfulMomentState.initial);
  }
}

final mindfulMomentProvider = StateNotifierProvider<MindfulMomentNotifier, MindfulMoment>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MindfulMomentNotifier(apiService);
});


// Notifier for managing article write operations
class ArticleNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final ApiService _apiService;

  ArticleNotifier(this._firestoreService, this._apiService) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> generateArticleContent(String prompt) async {
    state = const AsyncValue.loading();
    try {
      // Step 1: Generate text content from Gemini
      final fullPrompt = '''
        You are a content creator for a mindfulness and wellness app called Dhyana. Your tone is calm, insightful, and encouraging. Based on the following topic, generate a complete article.

        Topic: "$prompt"

        The output MUST be a valid JSON object with ONLY the following key-value pairs:
        {
          "title": "A compelling and concise title for the article",
          "category": "A relevant category (e.g., Mindfulness, Stress Relief, Nature Therapy, Personal Growth)",
          "author": "Dhyana Staff",
          "readingTimeMinutes": An estimated integer for reading time,
          "content": "The full article content, formatted in Markdown. It should include headings, paragraphs, and maybe a blockquote. Keep it between 300 and 500 words."
        }
      ''';

      final response = await _apiService.post(
        'v1beta/models/gemini-1.5-flash:generateContent',
        {
          'contents': [{'parts': [{'text': fullPrompt}]}]
        },
        headers: {'X-goog-api-key': AppConstants.geminiApiKey},
      );

      final content = response['candidates'][0]['content']['parts'][0]['text'];
      final cleanJsonString = content.replaceAll('```json', '').replaceAll('```', '').trim();
      final generatedData = jsonDecode(cleanJsonString) as Map<String, dynamic>;

      // Step 2: Search for a relevant image using the generated title
      if (generatedData.containsKey('title')) {
        final imageUrl = await _apiService.searchForImage(generatedData['title']);
        generatedData['imageUrl'] = imageUrl;
      }

      state = const AsyncValue.data(null);
      return generatedData;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<DocumentReference> addArticle(ArticleModel article) async {
    state = const AsyncValue.loading();
    try {
      final docRef = await _firestoreService.addArticle(article);
      state = const AsyncValue.data(null);
      return docRef;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateArticle(ArticleModel article) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateArticle(article);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteArticle(String articleId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteArticle(articleId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final articleNotifierProvider = StateNotifierProvider<ArticleNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return ArticleNotifier(firestoreService, apiService);
});