// lib/screens/profile/downloads_screen.dart
import 'dart:io';
import 'package:dhyana/models/music_track_model.dart';
import 'package:dhyana/providers/download_provider.dart';
import 'package:dhyana/providers/local_music_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

// Provider is now defined outside the widget, which is the correct approach.
final downloadedTasksProvider =
FutureProvider.autoDispose<List<DownloadTask>?>((ref) async {
  // autoDispose will help in automatically cleaning up the state when the screen is not in use.
  return await FlutterDownloader.loadTasksWithRawQuery(
    query: 'SELECT * FROM task WHERE status = 3',
  );
});

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  bool _showAllLocalMusic = false;

  @override
  Widget build(BuildContext context) {
    final downloadedTasksAsync = ref.watch(downloadedTasksProvider);
    final localMusic = ref.watch(localMusicProvider);
    final downloadState = ref.watch(downloadProvider);

    final displayedLocalMusic = _showAllLocalMusic
        ? localMusic
        : localMusic.take(3).toList();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Offline Music',
        showBackButton: true,
      ),
      body: CustomScrollView(
        slivers: [
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
          if (localMusic.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('From Your Device',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => ref.read(localMusicProvider.notifier).clearLocalMusic(),
                      child: const Text('Clear All'),
                    )
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final track = displayedLocalMusic[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.music_note, size: 40),
                      title: Text(track.title),
                      subtitle: Text(track.artist),
                      onTap: () {
                        context.push('/music-player', extra: {
                          'track': track,
                          'playlist': localMusic,
                        });
                      },
                    ),
                  );
                },
                childCount: displayedLocalMusic.length,
              ),
            ),
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
              )
          ],
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Text('App Downloads',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          downloadedTasksAsync.when(
            data: (tasks) {
              final appDownloads = tasks
                  ?.map((task) {
                final downloadInfo = downloadState[task.taskId];
                if (downloadInfo == null) return null;
                return MusicTrackModel(
                  id: task.taskId,
                  title: downloadInfo.title,
                  artist: 'Downloaded',
                  durationSeconds: 0,
                  imageUrl: downloadInfo.imageUrl,
                  localImagePath: downloadInfo.localImagePath,
                  audioUrl: '${task.savedDir}/${task.filename}',
                );
              })
                  .where((track) => track != null)
                  .cast<MusicTrackModel>()
                  .toList();

              if (appDownloads == null || appDownloads.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'You haven\'t downloaded any music from the app yet.',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final track = appDownloads[index];
                    final file = track.localImagePath != null
                        ? File(track.localImagePath!)
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (file != null && file.existsSync())
                              ? Image.file(
                            file,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.music_note_rounded,
                                size: 30, color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          track.title,
                          style: AppTextStyles.bodyLarge,
                        ),
                        subtitle: const Text('Downloaded'),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          onPressed: () {
                            context.push('/music-player', extra: {
                              'track': track,
                              'playlist': appDownloads,
                            });
                          },
                        ),
                      ),
                    );
                  },
                  childCount: appDownloads.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: LoadingWidget(message: 'Loading downloads...')),
            error: (e, st) => SliverToBoxAdapter(
                child: Center(child: Text('Error loading downloads: $e'))),
          ),
        ],
      ),
    );
  }
}