// lib/screens/articles/article_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:dhyana/core/utils/markdown_utils.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/providers/article_cache_provider.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/providers/tts_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:dhyana/widgets/common/tts_player_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/services/image_cache_service.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String? articleId;
  const ArticleDetailScreen({super.key, this.articleId});

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  bool _isTtsPlayerVisible = false;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null) {
      ref.read(progressNotifierProvider.notifier).logReadingTime(
        userId,
        _stopwatch.elapsed.inSeconds,
      );
    }
    ref.read(ttsProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleId = widget.articleId;
    if (articleId == null) {
      return const Scaffold(
        body: Center(child: Text("Article ID is missing.")),
      );
    }

    final articleContentAsync = ref.watch(articleContentProvider(articleId));
    final articlesAsync = ref.watch(articlesProvider);
    final isCached = ref.watch(articleCacheStateProvider(articleId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customCacheManager = ref.watch(customCacheManagerProvider);

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      floatingActionButton: !_isTtsPlayerVisible
          ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isTtsPlayerVisible = true;
          });
        },
        label: const Text("Read Aloud"),
        icon: const Icon(Icons.volume_up_outlined),
      )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: articlesAsync.when(
                  data: (groupedArticles) {
                    final allArticles =
                    groupedArticles.values.expand((list) => list);
                    ArticleModel? article;
                    try {
                      article =
                          allArticles.firstWhere((a) => a.id == articleId);
                    } catch (_) {
                      article = null;
                    }

                    if (article == null) {
                      return const Center(child: Text("Article not found."));
                    }

                    return CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 300,
                          pinned: true,
                          stretch: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          actions: [
                            IconButton(
                              icon: Icon(isCached
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_add_outlined),
                              tooltip: isCached
                                  ? 'Remove from Offline'
                                  : 'Save for Offline',
                              onPressed: () {
                                final notifier = ref.read(
                                    articleCacheStateProvider(articleId)
                                        .notifier);
                                if (isCached) {
                                  notifier.removeArticle(
                                      imageUrl: article?.imageUrl);
                                } else {
                                  articleContentAsync.whenData((content) {
                                    if (content != null) {
                                      notifier.saveArticle(
                                          content: content,
                                          imageUrl: article?.imageUrl);
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            stretchModes: const [StretchMode.zoomBackground],
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (article.imageUrl != null)
                                  CachedNetworkImage(
                                    cacheManager: customCacheManager,
                                    imageUrl: article.imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                    const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                  )
                                else
                                  Image.network(
                                    "https://placehold.co/600x400?text=Reading",
                                    fit: BoxFit.cover,
                                  ),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.center,
                                      colors: [
                                        Colors.black87,
                                        Colors.transparent
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.category.toUpperCase(),
                                        style: AppTextStyles.labelMedium
                                            .copyWith(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        article.title,
                                        style: AppTextStyles.headlineLarge
                                            .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "By ${article.author} • ${article.readingTimeMinutes} min read",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: (isDark
                                        ? AppColors.textDark
                                        : AppColors.textLight)
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const Divider(height: 40),
                                articleContentAsync.when(
                                  data: (content) => content != null
                                      ? MarkdownUtils.buildMarkdownBody(
                                      content, context)
                                      : const Text(
                                      "Article content could not be loaded."),
                                  loading: () => const LoadingWidget(
                                      message: "Loading article..."),
                                  error: (e, st) =>
                                      Text("Error loading content: $e"),
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                  const LoadingWidget(message: "Loading article..."),
                  error: (e, st) => Center(child: Text("Error: $e")),
                ),
              ),
              const MiniMusicPlayer(),
            ],
          ),
          if (_isTtsPlayerVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: TtsPlayerControls(
                articleContent: articleContentAsync.value,
                onClose: () {
                  ref.read(ttsProvider.notifier).stop();
                  setState(() {
                    _isTtsPlayerVisible = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}