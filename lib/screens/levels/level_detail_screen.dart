// lib/screens/levels/level_detail_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/utils/gamification_utils.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LevelDetailScreen extends ConsumerWidget {
  final Level level;

  const LevelDetailScreen({
    required this.level,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/levels');
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Level ${level.levelNumber}: ${level.title}',
          showBackButton: true,
        ),
        body: userProfileAsync.when(
          data: (user) {
            if (user == null) return const LoadingWidget();
            final progressAsync = ref.watch(userProgressDataProvider(user.id!));

            return progressAsync.when(
              data: (progress) {
                if (progress == null) return const LoadingWidget();

                final levelProgress = GamificationUtils.getUserLevelProgress(user, progress);
                final isLevelLocked = level.levelNumber > levelProgress.currentLevel.levelNumber;

                if (isLevelLocked) {
                  final gemsNeeded = level.gemsRequired - levelProgress.currentGems;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade600),
                          const SizedBox(height: 16),
                          Text('Level Locked', style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            'You need ${gemsNeeded > 0 ? gemsNeeded : 0} more 💎 to unlock this level.',
                            style: AppTextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final completedTaskIds = user.completedTaskIds;
                final tasks = level.tasks;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isCompleted = completedTaskIds.contains(task.id);

                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isCompleted ? Colors.green : Colors.grey,
                              size: 28.0,
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    task.description,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (task.navigationPath == '/journal') {
                                      context.push(task.navigationPath, extra: {
                                        'source': 'level_detail',
                                        'level': level
                                      });
                                    } else {
                                      context.push(task.navigationPath);
                                    }
                                  },
                                  child: const Text('Go'),
                                ),
                                TextButton(
                                  onPressed: isCompleted ? null : () {
                                    ref.read(taskCompletionServiceProvider).completeTask(task.id);
                                  },
                                  child: const Text('Mark Completed'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, st) =>
              const Center(child: Text('Could not load tasks.')),
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, st) =>
          const Center(child: Text('Could not load user profile.')),
        ),
      ),
    );
  }
}