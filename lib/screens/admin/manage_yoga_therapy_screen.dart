// lib/screens/admin/manage_yoga_therapy_screen.dart
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/providers/yoga_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageYogaTherapyScreen extends ConsumerWidget {
  const ManageYogaTherapyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yogaVideosAsync = ref.watch(yogaVideosProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Yoga Therapy',
        showBackButton: true,
      ),
      body: yogaVideosAsync.when(
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: Text('No yoga videos found. Tap + to add one.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10.0),
                  leading: Image.network(
                    video.thumbnailUrl,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.videocam_off),
                  ),
                  title: Text(video.title),
                  subtitle: Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit Video',
                        onPressed: () => context.push('/admin/add-edit-yoga-video', extra: video),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        tooltip: 'Delete Video',
                        onPressed: () async {
                          final confirm = await Helpers.showConfirmationDialog(
                            context,
                            title: 'Delete Video',
                            message: 'Are you sure you want to delete "${video.title}"?',
                            confirmText: 'Yes, Delete',
                          );
                          if (confirm == true) {
                            await ref.read(yogaNotifierProvider.notifier).deleteYogaVideo(video.id!);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => context.push('/admin/add-edit-yoga-video', extra: video),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading videos...'),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/add-edit-yoga-video'),
        child: const Icon(Icons.add),
      ),
    );
  }
}