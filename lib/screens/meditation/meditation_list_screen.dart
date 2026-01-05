// lib/screens/meditation/meditation_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/meditation_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/cards/meditation_category_row.dart';

class MeditationListScreen extends ConsumerWidget {
  const MeditationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final meditationsAsync = ref.watch(meditationsProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Meditate',
        showBackButton: false,
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
        child: meditationsAsync.when(
          data: (groupedMeditations) {
            if (groupedMeditations.isEmpty) {
              return Center(
                child: Text(
                  'No meditations available at the moment.',
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }

            final categories = groupedMeditations.keys.toList();

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
                style: const TextStyle(color: AppColors.errorColor)),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}