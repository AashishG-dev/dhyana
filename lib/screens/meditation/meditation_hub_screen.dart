// lib/screens/meditation/meditation_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';

class MeditationHubScreen extends StatelessWidget {
  const MeditationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Begin Your Practice',
        showBackButton: true,
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
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            _buildHubCard(
              context: context,
              icon: Icons.air,
              title: 'Breathing Techniques',
              description: 'Calm your mind with guided breathing patterns.',
              onTap: () => context.push('/meditate/breathing'),
              isDarkMode: isDarkMode,
            ),
            // ✅ FIX: Replaced Anxiety Relief with Reading Therapy
            _buildHubCard(
              context: context,
              icon: Icons.auto_stories, // A more fitting icon
              title: 'Reading Therapy',
              description: 'Find calm and inspiration through words.',
              onTap: () => context.push('/reading-therapy'),
              isDarkMode: isDarkMode,
            ),
            // ✅ FIX: Renamed this card for clarity
            _buildHubCard(
              context: context,
              icon: Icons.self_improvement,
              title: 'Guided Meditations',
              description: 'Listen to sessions for anxiety, sleep, and more.',
              onTap: () => context.push('/meditations'),
              isDarkMode: isDarkMode,
            ),
            _buildHubCard(
              context: context,
              icon: Icons.music_note,
              title: 'Music Therapy',
              description: 'Relax with a collection of calming soundscapes.',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Music Therapy coming soon!')),
                );
              },
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHubCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppConstants.paddingSmall / 2),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}