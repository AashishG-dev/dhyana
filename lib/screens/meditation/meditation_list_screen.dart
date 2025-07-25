// lib/screens/meditation/meditation_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/meditation_provider.dart'; // For meditationsProvider
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
// ✅ ADD: Import the new category row widget
import 'package:dhyana/widgets/cards/meditation_category_row.dart';

/// A screen that displays a list of available guided meditation sessions, grouped by category.
class MeditationListScreen extends ConsumerWidget {
  const MeditationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // ✅ FIX: The provider now returns a Map
    final meditationsAsync = ref.watch(meditationsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Meditate', // Changed title to be more engaging
        showBackButton: false, // This is a main screen, so no back button needed
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
        // ✅ FIX: Replaced the Column with a direct consumer of the provider
        child: meditationsAsync.when(
          data: (groupedMeditations) {
            if (groupedMeditations.isEmpty) {
              return Center(
                child: Text(
                  'No meditations available at the moment.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDarkMode ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              );
            }

            final categories = groupedMeditations.keys.toList();

            // Use a ListView to display the category rows vertically
            return ListView.builder(
              padding: const EdgeInsets.only(top: AppConstants.paddingLarge),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final meditations = groupedMeditations[category]!;
                return MeditationCategoryRow(
                  categoryTitle: category,
                  meditations: meditations,
                );
              },
            );
          },
          loading: () => const LoadingWidget(message: 'Loading meditations...'),
          error: (e, st) => Center(
            child: Text('Error loading meditations: $e',
                style: TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1), // Highlight Meditate tab
    );
  }
}