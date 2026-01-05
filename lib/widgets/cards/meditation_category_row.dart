import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/models/meditation_model.dart';
import 'package:dhyana/widgets/cards/meditation_card.dart';

class MeditationCategoryRow extends StatelessWidget {
  final String categoryTitle;
  final List<MeditationModel> meditations;

  const MeditationCategoryRow({
    required this.categoryTitle,
    required this.meditations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          child: Text(
            categoryTitle,
            style: AppTextStyles.headlineSmall,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium),
            itemCount: meditations.length,
            itemBuilder: (context, index) {
              final meditation = meditations[index];
              return SizedBox(
                width: 220,
                child: MeditationCard(
                  meditation: meditation,
                  onTap: () => context.go('/meditation-detail/${meditation.id}'),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
      ],
    );
  }
}
