// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/auth_provider.dart'; // For authStateProvider
import 'package:dhyana/providers/user_profile_provider.dart'; // For currentUserProfileProvider
import 'package:dhyana/providers/progress_provider.dart'; // For userProgressDataProvider
import 'package:dhyana/providers/meditation_provider.dart'; // For meditationsProvider
import 'package:dhyana/providers/article_provider.dart'; // For articlesProvider
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/progress_indicators/streak_indicator.dart';
import 'package:dhyana/widgets/progress_indicators/progress_chart_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final authUser = ref.watch(authStateProvider);
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dhyana',
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDarkMode ? AppColors.textDark : AppColors.textLight,
            ),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: authUser.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Not logged in.'));
            }

            return userProfileAsync.when(
              data: (userModel) {
                if (userModel == null) {
                  return const LoadingWidget(message: 'Setting up your profile...');
                }

                final progressDataAsync = ref.watch(userProgressDataProvider(userModel.id!));
                final meditationsAsync = ref.watch(meditationsProvider);
                final articlesAsync = ref.watch(articlesProvider);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${userModel.name.split(' ')[0]}!',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // --- Meditation Streak & Progress Chart ---
                      // ... (This part remains the same)

                      // --- Recommended Meditations ---
                      Text(
                        'Recommended Meditations',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      meditationsAsync.when(
                        // ✅ FIX: The data is now a Map<String, List<MeditationModel>>
                        data: (groupedMeditations) {
                          // Flatten the map's values into a single list of meditations.
                          final allMeditations = groupedMeditations.values.expand((list) => list).toList();

                          if (allMeditations.isEmpty) {
                            return const Text('No meditations available.');
                          }

                          return SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: allMeditations.length > 5 ? 5 : allMeditations.length,
                              itemBuilder: (context, index) {
                                // Now we can safely access items from the flattened list.
                                final meditation = allMeditations[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to the new detail screen
                                    context.go('/meditation-detail/${meditation.id}');
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.only(right: AppConstants.marginSmall),
                                    child: SizedBox(
                                      width: 150,
                                      child: Padding(
                                        padding: const EdgeInsets.all(AppConstants.paddingSmall),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 80,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                                image: meditation.imageUrl != null && meditation.imageUrl!.isNotEmpty
                                                    ? DecorationImage(
                                                  image: NetworkImage(meditation.imageUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                                    : null,
                                              ),
                                              child: (meditation.imageUrl == null || meditation.imageUrl!.isEmpty)
                                                  ? Center(child: Icon(Icons.self_improvement, size: 40, color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.5)))
                                                  : null,
                                            ),
                                            const SizedBox(height: AppConstants.paddingSmall),
                                            Text(
                                              meditation.title,
                                              style: AppTextStyles.titleSmall,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${meditation.durationMinutes} min',
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const LoadingWidget(),
                        error: (e, st) => Text('Error: $e', style: TextStyle(color: AppColors.errorColor)),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // --- Latest Articles ---
                      // ... (This part remains the same)
                    ],
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'Loading profile...'),
              error: (e, st) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Failed to load your profile.', style: TextStyle(color: AppColors.errorColor)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(currentUserProfileProvider),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const LoadingWidget(message: 'Checking authentication...'),
          error: (e, st) => Center(child: Text('Authentication error: $e', style: TextStyle(color: AppColors.errorColor))),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}