// lib/screens/meditation/offline_meditations_screen.dart
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/providers/download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OfflineMeditationsScreen extends ConsumerWidget {
  const OfflineMeditationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the single source of truth for all download info
    final allDownloads = ref.watch(downloadProvider);

    // Filter for completed meditation downloads directly from the provider's state
    final offlineMeditations = allDownloads.values
        .where((info) =>
    info.type == DownloadType.meditation &&
        info.status == DownloadTaskStatus.complete)
        .map((info) {
      // Reconstruct the MeditationModel from the stored DownloadInfo
      return MeditationModel(
        id: info.originalId,
        title: info.title,
        description: '', // Not needed for list view
        category: 'Downloaded',
        durationMinutes: 0, // Not available in download info
        imageUrl: info.imageUrl,
        localAudioPath:
        'path/to/downloads/${info.title}', // This will be replaced by the audio service
      );
    }).toList();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Offline Meditations',
        showBackButton: true,
      ),
      body: offlineMeditations.isEmpty
          ? Center(
        child: Text(
          'You haven\'t downloaded any meditations yet.',
          style: AppTextStyles.bodyLarge,
        ),
      )
          : ListView.builder(
        itemCount: offlineMeditations.length,
        itemBuilder: (context, index) {
          final meditation = offlineMeditations[index];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: meditation.imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: meditation.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.self_improvement,
                      size: 30, color: Colors.grey),
                ),
              ),
              title: Text(
                meditation.title,
                style: AppTextStyles.bodyLarge,
              ),
              subtitle: const Text('Downloaded'),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_outline_rounded),
                onPressed: () {
                  // The player will use the local path since it's available
                  context.push('/meditation-player/${meditation.id}');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}