// lib/screens/admin/laughing_therapy_management_screen.dart
import 'package:dhyana/providers/laughing_therapy_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LaughingTherapyManagementScreen extends ConsumerStatefulWidget {
  const LaughingTherapyManagementScreen({super.key});

  @override
  ConsumerState<LaughingTherapyManagementScreen> createState() =>
      _LaughingTherapyManagementScreenState();
}

class _LaughingTherapyManagementScreenState
    extends ConsumerState<LaughingTherapyManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memesAsync = ref.watch(memesProvider);
    final standupsAsync = ref.watch(standupVideosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Laughing Therapy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Memes'),
            Tab(text: 'Stand-up Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Memes Tab
          memesAsync.when(
            data: (memes) => ListView.builder(
              itemCount: memes.length,
              itemBuilder: (context, index) {
                final meme = memes[index];
                return ListTile(
                  leading: Image.network(meme.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(meme.caption ?? 'No Caption'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await ref
                          .read(laughingTherapyNotifierProvider.notifier)
                          .deleteMeme(meme.id!);
                    },
                  ),
                  onTap: () => context.push('/admin/manage-meme', extra: meme),
                );
              },
            ),
            loading: () => const LoadingWidget(),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
          // Stand-ups Tab
          standupsAsync.when(
            data: (videos) => ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return ListTile(
                  leading: Image.network(video.thumbnailUrl,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(video.title),
                  subtitle: Text(video.artist),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await ref
                          .read(laughingTherapyNotifierProvider.notifier)
                          .deleteStandupVideo(video.id!);
                    },
                  ),
                  onTap: () =>
                      context.push('/admin/manage-standup', extra: video),
                );
              },
            ),
            loading: () => const LoadingWidget(),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Use the manually managed controller to check the active tab
          if (_tabController.index == 0) {
            // Navigate to the screen for adding a new meme
            context.push('/admin/manage-meme');
          } else {
            // Navigate to the screen for adding a new stand-up video
            context.push('/admin/manage-standup');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}