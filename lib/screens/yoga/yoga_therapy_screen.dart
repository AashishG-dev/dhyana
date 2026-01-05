// lib/screens/yoga/yoga_therapy_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/data/yoga_data.dart';
import 'package:dhyana/models/yoga_pose_model.dart';
import 'package:dhyana/models/yoga_video_model.dart';
import 'package:dhyana/providers/yoga_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class YogaTherapyScreen extends ConsumerWidget {
  const YogaTherapyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final yogaVideosAsync = ref.watch(yogaVideosProvider);

    return Scaffold(
      backgroundColor:
      isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildSectionHeader(context, "Benefits of Yoga"),
          _buildBenefitsSection(isDarkMode),
          _buildSectionHeader(context, "Popular Asanas"),
          _buildAsanasSection(),
          _buildSectionHeader(context, "Guided Video Routines"),
          yogaVideosAsync.when(
            data: (videos) =>
                _buildVideosSection(context, ref, videos),
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(height: 250, child: LoadingWidget()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Could not load videos: $error')),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 40)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.backgroundDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              yogaHeaderUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.backgroundDark);
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yogaPageTitle,
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    yogaPageDescription,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white.withAlpha(230)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Text(
          title,
          style: AppTextStyles.headlineSmall,
        ),
      ),
    );
  }

  Widget _buildBenefitsSection(bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: isDarkMode ? AppColors.glassDarkSurface : Colors.white,
            borderRadius:
            BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(
              color: isDarkMode
                  ? AppColors.glassBorderDark
                  : AppColors.glassBorderLight,
            )),
        child: Column(
          children: yogaBenefits
              .map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 20,
                    color: isDarkMode
                        ? AppColors.primaryLightGreen
                        : AppColors.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                    child:
                    Text(benefit, style: AppTextStyles.bodyMedium)),
              ],
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAsanasSection() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final pose = yogaPoses[index];
          return _buildPoseCard(context, pose);
        },
        childCount: yogaPoses.length,
      ),
    );
  }

  Widget _buildVideosSection(BuildContext context, WidgetRef ref,
      List<YogaVideoModel> videos) {
    if (videos.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No guided videos available yet.'),
          ),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildVideoCard(context, ref, video);
          },
        ),
      ),
    );
  }

  Widget _buildPoseCard(BuildContext context, YogaPoseModel pose) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.network(pose.imageUrl,
              height: 200, width: double.infinity, fit: BoxFit.cover),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pose.sanskritName,
                    style: AppTextStyles.headlineSmall.copyWith(
                        color: isDarkMode
                            ? AppColors.primaryLightGreen
                            : AppColors.primaryBlue)),
                const SizedBox(height: 8),
                Text(pose.description, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/yoga/webview',
                          extra: {'url': pose.techniqueUrl, 'title': pose.name});
                    },
                    child: const Text('Learn the Technique'),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, WidgetRef ref,
      YogaVideoModel video) {
    return SizedBox(
      width: 280,
      child: Card(
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
                  'taskType': 'try_yoga',
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(video.thumbnailUrl,
                      height: 150, width: double.infinity, fit: BoxFit.cover),
                  Icon(Icons.play_circle_fill,
                      color: Colors.white.withAlpha(200), size: 50),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                video.title,
                style: AppTextStyles.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}