// lib/screens/profile/offline_screen.dart
import 'dart:io';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/models/music_track_model.dart';
import 'package:dhyana/providers/article_cache_provider.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/providers/download_provider.dart';
import 'package:dhyana/providers/local_music_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Provider to fetch all completed download tasks directly from the downloader plugin
final completedTasksProvider =
FutureProvider.autoDispose<List<DownloadTask>?>((ref) async {
  return await FlutterDownloader.loadTasksWithRawQuery(
    query: 'SELECT * FROM task WHERE status = 3', // Status 3 means complete
  );
});


class OfflineScreen extends ConsumerStatefulWidget {
  const OfflineScreen({super.key});

  @override
  ConsumerState<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends ConsumerState<OfflineScreen> {
  bool _showAllLocalMusic = false;

  @override
  Widget build(BuildContext context) {
    final downloadInfoState = ref.watch(downloadProvider);
    final completedTasksAsync = ref.watch(completedTasksProvider);
    final localMusic = ref.watch(localMusicProvider);
    final savedArticlesAsync = ref.watch(cachedArticlesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Offline Content',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Downloads',
            onPressed: () {
              ref.invalidate(completedTasksProvider);
              ref.invalidate(cachedArticlesProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(completedTasksProvider);
          ref.invalidate(cachedArticlesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Music from device section
            _buildSectionHeader('Music from Your Device'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(localMusicProvider.notifier).pickFiles(),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Add from Device'),
                ),
              ),
            ),
            if (localMusic.isEmpty)
              _buildEmptySection(
                  'Add local audio files from your device to play them here.')
            else
              _buildLocalMusicList(
                  _showAllLocalMusic ? localMusic : localMusic.take(3).toList()),

            if (localMusic.length > 3)
              SliverToBoxAdapter(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllLocalMusic = !_showAllLocalMusic;
                    });
                  },
                  child: Text(_showAllLocalMusic ? 'Show Less' : 'View More'),
                ),
              ),

            // App downloads section
            _buildSectionHeader('App Music Downloads'),
            completedTasksAsync.when(
              data: (tasks) {
                if (tasks == null || tasks.isEmpty) {
                  return _buildEmptySection(
                      'Music you download from the app will appear here.');
                }

                final offlineMusic = <MusicTrackModel>[];

                for (var task in tasks) {
                  final info = downloadInfoState[task.taskId];
                  if (info != null && info.type == DownloadType.music) {
                    offlineMusic.add(MusicTrackModel(
                      id: task.taskId,
                      title: info.title,
                      artist: 'Downloaded',
                      durationSeconds: 0,
                      imageUrl: info.imageUrl,
                      localImagePath: info.localImagePath,
                      audioUrl: '${task.savedDir}/${task.filename}',
                    ));
                  }
                }

                if (offlineMusic.isEmpty) {
                  return _buildEmptySection('No music downloaded yet.');
                }
                return _buildMusicList(offlineMusic, offlineMusic);
              },
              loading: () => const SliverToBoxAdapter(child: LoadingWidget()),
              error: (e, st) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),

            // Saved articles section
            _buildSectionHeader('Saved Articles'),
            savedArticlesAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return _buildEmptySection(
                      'No articles saved yet. Tap the bookmark icon on an article to save it.');
                }
                return _buildArticleList(articles);
              },
              loading: () => const SliverToBoxAdapter(child: LoadingWidget()),
              error: (e, st) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(message, style: AppTextStyles.bodyMedium),
      ),
    );
  }

  Widget _buildArticleList(List<ArticleModel> articles) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final article = articles[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: article.imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.article,
                      size: 30, color: Colors.grey),
                ),
              ),
              title: Text(article.title),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  final confirm = await Helpers.showConfirmationDialog(
                    context,
                    title: 'Remove Article',
                    message: 'Are you sure you want to remove this saved article?',
                  );
                  if (confirm == true) {
                    await ref.read(articleCacheStateProvider(article.id!).notifier).removeArticle(imageUrl: article.imageUrl);
                    ref.invalidate(cachedArticlesProvider);
                  }
                },
              ),
              onTap: () => context.push('/article-detail/${article.id}'),
            ),
          );
        },
        childCount: articles.length,
      ),
    );
  }

  Widget _buildMusicList(List<MusicTrackModel> tracks, List<MusicTrackModel> playlist) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final track = tracks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: track.localImagePath != null && File(track.localImagePath!).existsSync()
                    ? Image.file(
                  File(track.localImagePath!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.music_note,
                      size: 30, color: Colors.grey),
                ),
              ),
              title: Text(track.title),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  final confirm = await Helpers.showConfirmationDialog(
                    context,
                    title: 'Delete Download',
                    message: 'Are you sure you want to delete this downloaded track?',
                  );
                  if (confirm == true) {
                    await ref.read(downloadProvider.notifier).deleteDownload(track.id);
                    ref.invalidate(completedTasksProvider);
                  }
                },
              ),
              onTap: () => context
                  .push('/music-player', extra: {'track': track, 'playlist': playlist}),
            ),
          );
        },
        childCount: tracks.length,
      ),
    );
  }

  Widget _buildLocalMusicList(List<MusicTrackModel> tracks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final track = tracks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.music_note, size: 40),
              title: Text(track.title),
              subtitle: Text(track.artist),
              trailing: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  // This is a placeholder for deleting local music
                  // You would need to implement the logic in your LocalMusicNotifier
                },
              ),
              onTap: () {
                context.push('/music-player',
                    extra: {'track': track, 'playlist': tracks});
              },
            ),
          );
        },
        childCount: tracks.length,
      ),
    );
  }
}