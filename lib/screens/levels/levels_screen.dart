// lib/screens/levels/levels_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/utils/gamification_utils.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/timeline_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  void _showHowToEarnGemsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Earn Gems'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGemTask(
                icon: Icons.spa, text: 'Meditate/Breathe: 10 💎 / min'),
            _buildGemTask(
                icon: Icons.menu_book,
                text: 'Read/Yoga: 15 💎 / min'),
            _buildGemTask(
                icon: Icons.music_note,
                text: 'Listen to Music: 10 💎 / min'),
            _buildGemTask(
                icon: Icons.edit, text: 'Write in Journal: 50 💎 / entry'),
            _buildGemTask(
                icon: Icons.chat,
                text: 'Talk to Dhyana AI: 5 💎 / message'),
            _buildGemTask(
                icon: Icons.local_fire_department,
                text: 'Daily Streak: 100 💎 bonus'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          )
        ],
      ),
    );
  }

  Widget _buildGemTask({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLightGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLevels = GamificationUtils.allLevels;
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Path',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to Earn Gems',
            onPressed: () => _showHowToEarnGemsDialog(context),
          )
        ],
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) return const LoadingWidget();
          final progressAsync = ref.watch(userProgressDataProvider(user.id!));
          return progressAsync.when(
            data: (progress) {
              final progressData =
                  progress ?? ProgressDataModel(userId: user.id!);
              final levelProgress =
              GamificationUtils.getUserLevelProgress(user, progressData);
              final currentLevelNum = levelProgress.currentLevel.levelNumber;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: allLevels.length,
                itemBuilder: (context, index) {
                  final level = allLevels[index];
                  return GestureDetector(
                    onTap: () {
                      context.go('/level-detail', extra: level);
                    },
                    child: TimelineTile(
                      isFirst: index == 0,
                      isLast: index == allLevels.length - 1,
                      isCompleted: level.levelNumber < currentLevelNum,
                      isCurrent: level.levelNumber == currentLevelNum,
                      title: 'Level ${level.levelNumber}: ${level.title}',
                      description: level.description,
                      points: Row(
                        children: [
                          Icon(Icons.diamond_outlined, size: 16, color: activeColor),
                          const SizedBox(width: 6),
                          Text(
                            'Requires ${level.gemsRequired} Gems',
                            style: AppTextStyles.labelMedium.copyWith(color: activeColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const LoadingWidget(),
            error: (e, st) =>
            const Center(child: Text('Error loading progress.')),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, st) =>
        const Center(child: Text('Error loading your profile.')),
      ),
    );
  }
}