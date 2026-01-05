// lib/screens/music/music_player_screen.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:dhyana/models/music_track_model.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/providers/download_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  final MusicTrackModel track;
  final List<MusicTrackModel> playlist;

  const MusicPlayerScreen(
      {required this.track, required this.playlist, super.key});

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> {
  Timer? _sleepTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(musicPlayerProvider.notifier)
            .play(widget.track, widget.playlist);
      }
    });
  }

  Future<void> _requestDownload(MusicTrackModel track) async {
    final downloadTasks = ref.read(downloadProvider);
    final isAlreadyDownloaded = downloadTasks.values.any((info) =>
    info.type == DownloadType.music &&
        info.originalId == track.id &&
        info.status == DownloadTaskStatus.complete);

    if (isAlreadyDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This track is already downloaded.')),
      );
      return;
    }

    Permission storagePermission;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        storagePermission = Permission.audio;
      } else {
        storagePermission = Permission.storage;
      }
    } else {
      storagePermission = Permission.storage;
    }

    final status = await storagePermission.status;

    if (status.isGranted) {
      await ref.read(downloadProvider.notifier).enqueueMusicDownload(track);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download started...')),
        );
      }
    } else {
      final result = await storagePermission.request();
      if (result.isGranted) {
        await ref.read(downloadProvider.notifier).enqueueMusicDownload(track);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started...')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Storage permission is required to download music.')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  void _setSleepTimer(int minutes) {
    if (minutes <= 0) return;
    _sleepTimer?.cancel();
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      if (mounted) {
        ref.read(musicPlayerProvider.notifier).pause();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sleep timer finished. Music paused.')));
      }
    });
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Music will stop in $minutes minutes.')));
  }

  void _showSleepTimerOptions() {
    final TextEditingController controller = TextEditingController();
    bool isCustomView = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetSetState) {
            Widget buildCustomView() {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Set Custom Timer',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        labelText: "Minutes",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              sheetSetState(() => isCustomView = false),
                          child: const Text('Back'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final int? minutes =
                            int.tryParse(controller.text);
                            if (minutes != null) {
                              _setSleepTimer(minutes);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Set'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            Widget buildPresetView() {
              return Wrap(
                children: <Widget>[
                  ListTile(
                      title: Center(
                          child: Text('Sleep Timer',
                              style:
                              Theme.of(context).textTheme.titleLarge))),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('15 minutes'),
                    onTap: () => _setSleepTimer(15),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('30 minutes'),
                    onTap: () => _setSleepTimer(30),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('60 minutes'),
                    onTap: () => _setSleepTimer(60),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Set Custom Time...'),
                    onTap: () => sheetSetState(() => isCustomView = true),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.cancel_outlined),
                    title: const Text('Cancel Timer'),
                    onTap: () {
                      _sleepTimer?.cancel();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sleep timer cancelled.')));
                    },
                  ),
                ],
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: isCustomView ? buildCustomView() : buildPresetView(),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
    }
  }

  Color _getRepeatIconColor(RepeatMode mode, BuildContext context) {
    if (mode == RepeatMode.off) {
      return Colors.white70;
    }
    return Theme.of(context).colorScheme.primary;
  }

  // Helper widget to decide which image to show
  Widget _buildPlayerImage(MusicTrackModel track, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.7;
    // Check if there is a local image path
    if (track.localImagePath != null && track.localImagePath!.isNotEmpty) {
      final file = File(track.localImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: screenWidth,
          width: screenWidth,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(screenWidth),
        );
      }
    }
    // Check if there is a network image URL
    if (track.imageUrl != null && track.imageUrl!.startsWith('http')) {
      return Image.network(
        track.imageUrl!,
        height: screenWidth,
        width: screenWidth,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImagePlaceholder(screenWidth),
      );
    }
    // Fallback placeholder
    return _buildImagePlaceholder(screenWidth);
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      height: size,
      width: size,
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 64),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicPlayerState = ref.watch(musicPlayerProvider);
    final playerState = musicPlayerState.playerState;
    final currentTrack = musicPlayerState.currentTrack ?? widget.track;
    final repeatMode = musicPlayerState.repeatMode;

    final position =
        ref.watch(currentMusicPositionProvider).value ?? Duration.zero;
    final duration =
        ref.watch(currentMusicDurationProvider).value ?? Duration.zero;

    final downloadTasks = ref.watch(downloadProvider);

    ref.listen<MusicPlayerState>(musicPlayerProvider, (previous, next) {
      if (previous?.currentTrack != null &&
          next.playerState == PlayerState.stopped) {
        ref.read(taskCompletionServiceProvider).completeTask('listen_music');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: (currentTrack.localImagePath != null &&
                      currentTrack.localImagePath!.isNotEmpty &&
                      File(currentTrack.localImagePath!).existsSync())
                      ? FileImage(File(currentTrack.localImagePath!))
                      : (currentTrack.imageUrl != null &&
                      currentTrack.imageUrl!.startsWith('http'))
                      ? NetworkImage(currentTrack.imageUrl!)
                      : const AssetImage('assets/images/default_music.jpg')
                  as ImageProvider,
                  fit: BoxFit.cover),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(color: Colors.black.withAlpha(128)), // Use withAlpha
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Text('Now Playing',
                          style: AppTextStyles.titleMedium
                              .copyWith(color: Colors.white)),
                      Row(
                        children: [
                          _buildDownloadButton(currentTrack, downloadTasks),
                          IconButton(
                            icon: const Icon(Icons.nightlight_round,
                                color: Colors.white),
                            tooltip: 'Sleep Timer',
                            onPressed: _showSleepTimerOptions,
                          ),
                          IconButton(
                            icon: const Icon(Icons.download_for_offline,
                                color: Colors.white),
                            tooltip: 'Offline Music',
                            onPressed: () => context.push('/offline-content'),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: _buildPlayerImage(currentTrack, context),
                  ),
                  const SizedBox(height: 32),
                  Text(currentTrack.title,
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: Colors.white),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(currentTrack.artist,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: Colors.white70)),
                  const Spacer(),
                  Column(
                    children: [
                      Slider(
                        value: position.inSeconds
                            .toDouble()
                            .clamp(0.0, duration.inSeconds.toDouble()),
                        max: duration.inSeconds.toDouble() > 0
                            ? duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          ref
                              .read(musicPlayerProvider.notifier)
                              .seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: Colors.white,
                        inactiveColor:
                        Colors.white.withAlpha(77), // Use withAlpha
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position),
                                style:
                                const TextStyle(color: Colors.white70)),
                            Text(_formatDuration(duration),
                                style:
                                const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          _getRepeatIcon(repeatMode),
                          color: _getRepeatIconColor(repeatMode, context),
                          size: 28,
                        ),
                        onPressed: () => ref
                            .read(musicPlayerProvider.notifier)
                            .toggleRepeatMode(),
                      ),
                      IconButton(
                          icon: const Icon(Icons.skip_previous_rounded,
                              color: Colors.white, size: 36),
                          onPressed: () => ref
                              .read(musicPlayerProvider.notifier)
                              .playPrevious()),
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: musicPlayerState.isBuffering
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : IconButton(
                          icon: Icon(
                            playerState == PlayerState.playing
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            final notifier =
                            ref.read(musicPlayerProvider.notifier);
                            if (playerState == PlayerState.playing) {
                              notifier.pause();
                            } else {
                              notifier.play(
                                  currentTrack, widget.playlist);
                            }
                          },
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.skip_next_rounded,
                              color: Colors.white, size: 36),
                          onPressed: () => ref
                              .read(musicPlayerProvider.notifier)
                              .playNext()),
                      const SizedBox(width: 28),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
      MusicTrackModel track, Map<String, DownloadInfo> tasks) {
    if (!track.audioUrl.startsWith('http')) {
      return const IconButton(
        icon: Icon(Icons.check_circle, color: Colors.white),
        tooltip: 'Downloaded',
        onPressed: null,
      );
    }

    final taskEntry = tasks.entries.firstWhere(
          (entry) =>
      entry.value.type == DownloadType.music &&
          entry.value.originalId == track.id,
      orElse: () => MapEntry(
          '',
          DownloadInfo(
              taskId: '',
              title: '',
              status: DownloadTaskStatus.undefined,
              progress: 0,
              type: DownloadType.music,
              originalId: track.id)),
    );

    final task = taskEntry.key.isNotEmpty ? taskEntry.value : null;

    if (task != null) {
      if (task.status == DownloadTaskStatus.running) {
        return SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  value: (task.progress) / 100,
                  color: Colors.white,
                  strokeWidth: 2.0),
            ),
          ),
        );
      }

      if (task.status == DownloadTaskStatus.complete) {
        return const IconButton(
          icon: Icon(Icons.check_circle, color: Colors.white),
          tooltip: 'Downloaded',
          onPressed: null,
        );
      }
    }

    return IconButton(
      icon:
      const Icon(Icons.download_for_offline_outlined, color: Colors.white),
      tooltip: 'Download for Offline Playback',
      onPressed: () => _requestDownload(track),
    );
  }
}