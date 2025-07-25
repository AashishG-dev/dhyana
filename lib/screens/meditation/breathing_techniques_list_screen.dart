// lib/screens/meditation/breathing_techniques_list_screen.dart
import 'package:dhyana/data/breathing_techniques_data.dart';
import 'package:dhyana/models/breathing_technique_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
// ✅ FIX: Corrected the typo in the import path from '.' to ':'.
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';

class BreathingTechniquesListScreen extends StatelessWidget {
  const BreathingTechniquesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'Breathing Techniques', showBackButton: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Breathing is one of the simplest and most powerful tools to regulate your nervous system. These techniques can help you reduce stress, improve focus, and find calm in minutes.',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: isDarkMode ? AppColors.textDark : AppColors.textLight
              ),
            ),
            const SizedBox(height: 24),
            ...breathingTechniques.map((technique) => _buildTechniqueCard(context, technique, isDarkMode)).toList(),
          ],
        ),
      ),
    );
  }
}

Widget _buildTechniqueCard(BuildContext context, BreathingTechnique technique, bool isDarkMode) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16.0),
    child: InkWell(
      onTap: () => context.push('/meditate/breathing/${technique.id}'),
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(technique.title, style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              technique.shortDescription,
              style: AppTextStyles.bodyMedium.copyWith(
                color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}