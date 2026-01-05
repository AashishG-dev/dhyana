// lib/screens/meditation/meditation_detail_screen.dart
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/meditation_provider.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class MeditationDetailScreen extends ConsumerWidget {
  final String meditationId;
  const MeditationDetailScreen({required this.meditationId, super.key});

  Future<void> _requestDownloadPermission(
      BuildContext context, WidgetRef ref, meditation) async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      await ref
          .read(downloadProvider.notifier)
          .enqueueMeditationDownload(meditation);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download started...')),
        );
      }
    } else {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        await ref
            .read(downloadProvider.notifier)
            .enqueueMeditationDownload(meditation);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started...')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                Text('Storage permission is required to download music.')),
          );
        }
      }
    }
  }

  Widget _buildDownloadButton(
      BuildContext context, WidgetRef ref, meditation) {
    final downloadTasks = ref.watch(downloadProvider);
    final taskEntry = downloadTasks.entries.firstWhere(
          (entry) =>
      entry.value.type == DownloadType.meditation &&
          entry.value.originalId == meditationId,
      orElse: () => MapEntry(
          '',
          DownloadInfo(
              taskId: '',
              title: '',
              status: DownloadTaskStatus.undefined,
              progress: 0,
              type: DownloadType.meditation,
              originalId: '')),
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
          icon: Icon(Icons.check_circle, color: Colors.white, size: 30),
          tooltip: 'Downloaded',
          onPressed: null,
        );
      }
    }

    return IconButton(
      icon: const Icon(Icons.download_for_offline_outlined,
          color: Colors.white, size: 30),
      tooltip: 'Download for Offline Playback',
      onPressed: () => _requestDownloadPermission(context, ref, meditation),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditationAsync = ref.watch(meditationByIdProvider(meditationId));
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      body: meditationAsync.when(
        data: (meditation) {
          if (meditation == null) {
            return const Center(child: Text('Meditation not found.'));
          }

          final isFavorite = userProfileAsync.when(
            data: (user) =>
            user?.favoriteMeditationIds.contains(meditationId) ?? false,
            loading: () => false,
            error: (e, s) => false,
          );

          final formattedPlayCount =
          NumberFormat.compact().format(meditation.playCount);

          return Stack(
            children: [
              if (meditation.imageUrl != null &&
                  meditation.imageUrl!.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    meditation.imageUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withAlpha(102),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Row(
                        children: [
                          _buildDownloadButton(context, ref, meditation),
                          userProfileAsync.when(
                            data: (user) => IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? Colors.redAccent
                                    : Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                if (user != null && user.id != null) {
                                  ref
                                      .read(userProfileNotifierProvider
                                      .notifier)
                                      .toggleFavoriteMeditation(
                                      user.id!, meditationId);
                                }
                              },
                            ),
                            loading: () => const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.0)),
                            ),
                            error: (e, s) =>
                            const Icon(Icons.error, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meditation.title,
                          style: AppTextStyles.displayLarge
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Row(
                        children: [
                          _buildTag('${meditation.durationMinutes} min'),
                          _buildTag(meditation.voiceType),
                          _buildTag(meditation.category),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        meditation.description,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: Colors.white.withAlpha(230)),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        '$formattedPlayCount plays',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white.withAlpha(179)),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge * 2),
                      CustomButton(
                        text: 'Begin',
                        onPressed: () {
                          context.push('/meditation-player/${meditation.id}');
                        },
                        type: ButtonType.primary,
                        icon: Icons.play_arrow,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading Meditation...'),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      margin: const EdgeInsets.only(right: AppConstants.marginSmall),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white
              .withAlpha(38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(77))
      ),
      child: Text(text,
          style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
    );
  }
}