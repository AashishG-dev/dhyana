// lib/screens/meditation/breathing_techniques_list_screen.dart
import 'package:dhyana/data/breathing_techniques_data.dart';
import 'package:dhyana/models/breathing_technique_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

class BreathingTechniquesListScreen extends StatelessWidget {
  const BreathingTechniquesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ✅ UPDATED: Theme-aware colors
    final backgroundColor = isDarkMode ? const Color(0xFF0D1F2D) : AppColors.backgroundLight;
    final textColor = isDarkMode ? Colors.white : AppColors.textLight;
    final secondaryTextColor = isDarkMode ? Colors.white.withAlpha(179) : AppColors.textLight.withAlpha(179);
    final cardBackgroundColor = isDarkMode ? const Color(0xFF1E2A3A) : Colors.white;
    final iconBackgroundColor = isDarkMode ? Colors.black.withAlpha(51) : AppColors.primaryLightBlue.withAlpha(25);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => context.pop(),
              ),
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Breathing techniques',
                                style: AppTextStyles.headlineLarge.copyWith(color: textColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Discover and try the best breathing techniques to reduce stress & anxiety',
                                style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                icon: Icon(Icons.info_outline, color: secondaryTextColor, size: 16),
                                label: Text(
                                  'Research sources',
                                  style: AppTextStyles.labelMedium.copyWith(color: secondaryTextColor),
                                ),
                                onPressed: () {
                                  // TODO: Implement navigation to research sources
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final technique = breathingTechniques[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildTechniqueCard(
                      context,
                      technique,
                      cardBackgroundColor,
                      textColor,
                      secondaryTextColor,
                      iconBackgroundColor,
                    ),
                  );
                },
                childCount: breathingTechniques.length,
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechniqueCard(
      BuildContext context,
      BreathingTechnique technique,
      Color cardBackgroundColor,
      Color textColor,
      Color secondaryTextColor,
      Color iconBackgroundColor,
      ) {
    return GestureDetector(
      onTap: () {
        if (technique.isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This feature is coming soon!')),
          );
        } else {
          context.push('/meditate/breathing/${technique.id}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: Theme.of(context).brightness == Brightness.light
              ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(technique.icon, color: textColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    technique.title,
                    style: AppTextStyles.titleLarge.copyWith(color: textColor),
                  ),
                ),
                if (technique.isLocked)
                  Icon(Icons.lock_outline, color: secondaryTextColor, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              technique.shortDescription,
              style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: technique.tagColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    technique.tag,
                    style: AppTextStyles.labelSmall.copyWith(color: technique.tagColor),
                  ),
                ),
                const Spacer(),
                Icon(Icons.timer_outlined, color: secondaryTextColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  technique.durationText,
                  style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}