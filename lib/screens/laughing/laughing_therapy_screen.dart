// lib/screens/laughing/laughing_therapy_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/data/laughing_therapy_data.dart';
import 'package:dhyana/models/standup_video_model.dart';
import 'package:dhyana/providers/laughing_therapy_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LaughingTherapyScreen extends StatelessWidget {
  const LaughingTherapyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _Header(),
          _SectionHeader(title: "ABOUT"),
          _AboutSection(),
          _SectionHeader(title: "MEMES"),
          _MemesSection(),
          _SectionHeader(title: "STANDUPS"),
          _StandupsSection(),
          SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      backgroundColor: Colors.black,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              laughingTherapyHeaderUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      laughingTherapyTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      laughingTherapySubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: Colors.orangeAccent, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.headlineSmall
                .copyWith(color: Colors.white, letterSpacing: 2),
          ),
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(aboutSectionImageUrl),
            ),
            const SizedBox(height: 32),
            Text(
              "Laughter Yoga includes four things:",
              style:
              AppTextStyles.titleLarge.copyWith(color: AppColors.accentCyan),
            ),
            const SizedBox(height: 16),
            ...laughterYogaPoints.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(point,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: Colors.white70)),
            )),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                context.push('/yoga/webview', extra: {
                  'url': 'https://www.healthline.com/nutrition/laughing-yoga',
                  'title': 'About Laughter Yoga',
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentCyan,
                side: const BorderSide(color: AppColors.accentCyan),
              ),
              child: const Text("Know More"),
            )
          ],
        ),
      ),
    );
  }
}

class _MemesSection extends ConsumerWidget {
  const _MemesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memesAsync = ref.watch(memesProvider);
    return SliverToBoxAdapter(
      child: memesAsync.when(
        data: (memes) {
          if (memes.isEmpty) {
            return const Center(
                child: Text('No memes yet!',
                    style: TextStyle(color: Colors.white70)));
          }
          return Column(
            children: [
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: memes.length > 3
                      ? 3
                      : memes.length, // Show up to 3 memes in preview
                  itemBuilder: (context, index) {
                    final meme = memes[index];
                    return Column(
                      children: [
                        Expanded(
                          child:
                          Image.network(meme.imageUrl, fit: BoxFit.contain),
                        ),
                        if (meme.caption != null && meme.caption!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(meme.caption!,
                                style:
                                const TextStyle(color: Colors.white70)),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/laughing/memes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Explore More Memes"),
              )
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, st) => Center(
            child: Text('Could not load memes.',
                style: TextStyle(color: Colors.red.shade300))),
      ),
    );
  }
}

class _StandupsSection extends ConsumerWidget {
  const _StandupsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standupsAsync = ref.watch(standupVideosProvider);

    return SliverToBoxAdapter(
      child: standupsAsync.when(
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
                child: Text('No videos yet!',
                    style: TextStyle(color: Colors.white70)));
          }
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return _buildVideoCard(context, ref, video);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, st) => Center(
            child: Text('Could not load videos.',
                style: TextStyle(color: Colors.red.shade300))),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, WidgetRef ref,
      StandupVideoModel video) {
    return SizedBox(
      width: 200,
      child: Card(
        color: const Color(0xFF1A1A1A),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                context.push('/yoga/video', extra: {
                  'videoId': video.videoId,
                  'title': video.title,
                  'taskType': 'laugh_therapy',
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(video.thumbnailUrl,
                      height: 120, width: double.infinity, fit: BoxFit.cover),
                  Icon(Icons.play_circle_fill,
                      color: Colors.white.withAlpha(200), size: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                video.title,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    video.artist,
                    style:
                    AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}