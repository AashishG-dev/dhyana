// lib/screens/profile/profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/onboarding_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmText: 'Yes, Logout',
    );

    if (confirm != true || !context.mounted) return;

    try {
      // ✅ ADDED: This tells the router that a logout has occurred
      // so it can redirect to the welcome screen properly.
      await ref.read(onboardingNotifierProvider.notifier).handleLogoutRedirect();
      await ref.read(authServiceProvider).logout();
    } catch (e) {
      if (!context.mounted) return;
      Helpers.showMessageDialog(context,
          title: 'Error', message: 'Could not log out. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (authUser == null) {
      return const Scaffold(body: Center(child: LoadingWidget()));
    }

    final progressDataAsync = ref.watch(userProgressDataProvider(authUser.uid));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: userProfileAsync.when(
          data: (user) {
            if (user == null) return const LoadingWidget(message: 'Loading profile...');

            final hasValidImage = user.profilePictureUrl != null && user.profilePictureUrl!.startsWith('http');

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/home'),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push('/settings'),
                      tooltip: 'Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => _handleLogout(context, ref),
                      tooltip: 'Logout',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(bottom: 16.0),
                    title: Text(
                        user.name,
                        style: AppTextStyles.titleLarge.copyWith(color: Colors.white, shadows: [const Shadow(blurRadius: 2)])
                    ),
                    background: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
                        final deltaExtent = settings.maxExtent - settings.minExtent;
                        final t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);
                        final double opacity = 1.0 - t;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if (!hasValidImage)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      isDarkMode ? AppColors.primaryBlue : AppColors.primaryPurple,
                                      isDarkMode ? AppColors.accentCyan : AppColors.accentPink,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            if (hasValidImage)
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Image.network(
                                  user.profilePictureUrl!,
                                  fit: BoxFit.cover,
                                  color: Colors.black.withAlpha(102),
                                  colorBlendMode: BlendMode.darken,
                                ),
                              ),
                            Opacity(
                              opacity: opacity,
                              child: Stack(
                                children: [
                                  Center(
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(204),
                                      backgroundImage: hasValidImage ? NetworkImage(user.profilePictureUrl!) : null,
                                      child: !hasValidImage && user.name.isNotEmpty
                                          ? Text(
                                        user.name[0].toUpperCase(),
                                        style: AppTextStyles.displayLarge.copyWith(color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryBlue),
                                      )
                                          : null,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: FloatingActionButton.small(
                                        onPressed: () {
                                          context.push('/edit-profile');
                                        },
                                        child: const Icon(Icons.edit),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: progressDataAsync.when(
                      data: (progress) {
                        if (progress == null) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Start an activity to see your progress!')));
                        final mindfulnessLevel = progress.mindfulnessLevel;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMindfulnessLevelCard(context, mindfulnessLevel),
                            const SizedBox(height: 24),
                            Text('Statistics', style: AppTextStyles.headlineSmall),
                            const SizedBox(height: 16),
                            _buildStatsGrid(context, progress),
                            if (user.role == 'admin')
                              Card(
                                margin: const EdgeInsets.only(top: 24.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.admin_panel_settings),
                                      title: const Text('Admin Portal'),
                                      subtitle: const Text('Manage app content'),
                                      trailing: const Icon(Icons.arrow_forward_ios),
                                      onTap: () => context.push('/admin-portal'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                      loading: () => const LoadingWidget(),
                      error: (e, st) => Text('Error loading progress: $e'),
                    ),
                  ),
                )
              ],
            );
          },
          loading: () => const LoadingWidget(message: 'Loading profile...'),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4), // Set appropriate index
      ),
    );
  }

  Widget _buildMindfulnessLevelCard(BuildContext context, MindfulnessLevel level) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: level.progress,
              center: Text('${(level.progress * 100).toInt()}%', style: AppTextStyles.titleMedium),
              progressColor: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryBlue,
              backgroundColor: (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryBlue).withAlpha(51),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.name, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    level.pointsToNextLevel > 0
                        ? '${level.pointsToNextLevel} points to the next level'
                        : 'You\'ve reached the highest level!',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProgressDataModel progress) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(context, 'Streak', progress.meditationStreak.toString(), Icons.local_fire_department_outlined),
        _buildStatCard(context, 'Meditated', '${progress.totalMeditationMinutes} min', Icons.self_improvement_outlined),
        _buildStatCard(context, 'Time Reading', '${(progress.totalReadingSeconds / 60).floor()} min', Icons.menu_book_outlined),
        _buildStatCard(context, 'Listened', '${(progress.totalMusicSeconds / 60).floor()} min', Icons.music_note_outlined),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryBlue),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.headlineSmall, overflow: TextOverflow.ellipsis),
                Text(title, style: AppTextStyles.bodyMedium),
              ],
            )
          ],
        ),
      ),
    );
  }
}