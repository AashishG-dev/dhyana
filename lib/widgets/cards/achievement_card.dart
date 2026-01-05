// lib/widgets/cards/achievement_card.dart
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/models/achievement_model.dart';
import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    required this.achievement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: achievement.color.withOpacity(0.2),
              child: Icon(
                achievement.icon,
                size: 30,
                color: achievement.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}