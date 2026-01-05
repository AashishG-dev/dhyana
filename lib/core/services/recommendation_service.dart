// lib/core/services/recommendation_service.dart
import 'package:dhyana/models/recommendation_model.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:flutter/material.dart';

class RecommendationService {
  List<Recommendation> getRecommendations(UserModel user) {
    final Map<String, double> scores = {
      'breathing': 0,
      'reading': 0,
      'music': 0,
      'yoga': 0,
      'laughing': 0,
      'journaling': 0,
    };

    // Score based on goals
    for (String goal in user.meditationGoals) {
      switch (goal) {
        case 'Reduce Stress':
          scores['breathing'] = (scores['breathing'] ?? 0) + 1.5;
          scores['yoga'] = (scores['yoga'] ?? 0) + 1.0;
          scores['music'] = (scores['music'] ?? 0) + 1.0;
          break;
        case 'Improve Focus':
          scores['reading'] = (scores['reading'] ?? 0) + 1.5;
          scores['breathing'] = (scores['breathing'] ?? 0) + 1.0;
          break;
        case 'Increase Happiness':
          scores['laughing'] = (scores['laughing'] ?? 0) + 1.5;
          scores['music'] = (scores['music'] ?? 0) + 1.0;
          break;
        case 'Better Sleep':
          scores['music'] = (scores['music'] ?? 0) + 1.5;
          scores['breathing'] = (scores['breathing'] ?? 0) + 1.0;
          break;
        case 'Self-Esteem':
          scores['journaling'] = (scores['journaling'] ?? 0) + 1.5;
          scores['reading'] = (scores['reading'] ?? 0) + 1.0;
          break;
      }
    }

    // Score based on preferred activities
    for (String activity in user.preferredActivities) {
      scores[activity.toLowerCase()] =
          (scores[activity.toLowerCase()] ?? 0) + 2.0;
    }

    // Score based on current mood
    switch (user.currentMood) {
      case 'Stressed':
      case 'Anxious':
        scores['breathing'] = (scores['breathing'] ?? 0) + 2.0;
        scores['yoga'] = (scores['yoga'] ?? 0) + 1.5;
        break;
      case 'Sad':
        scores['journaling'] = (scores['journaling'] ?? 0) + 2.0;
        scores['laughing'] = (scores['laughing'] ?? 0) + 1.5;
        break;
      case 'Happy':
      case 'Calm':
        scores['music'] = (scores['music'] ?? 0) + 1.0;
        scores['reading'] = (scores['reading'] ?? 0) + 1.0;
        break;
    }

    final sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendations = <Recommendation>[];
    for (var entry in sortedScores) {
      if (entry.value > 0) {
        recommendations.add(_getRecommendationForType(entry.key));
      }
    }

    if (recommendations.isEmpty) {
      return [
        const Recommendation(
          title: 'Start Your Journey',
          description: 'Explore a variety of mindfulness activities.',
          icon: Icons.explore,
          route: '/meditate',
        )
      ];
    }

    return recommendations.take(3).toList();
  }

  Recommendation _getRecommendationForType(String type) {
    switch (type) {
      case 'breathing':
        return const Recommendation(
          title: 'Breathing Exercise',
          description: 'Calm your mind and body.',
          icon: Icons.air,
          route: '/meditate/breathing',
        );
      case 'reading':
        return const Recommendation(
          title: 'Mindful Reading',
          description: 'Gain insights and knowledge.',
          icon: Icons.auto_stories,
          route: '/reading-therapy',
        );
      case 'music':
        return const Recommendation(
          title: 'Listen to Music',
          description: 'Relax with calming melodies.',
          icon: Icons.music_note,
          route: '/music-therapy',
        );
      case 'yoga':
        return const Recommendation(
          title: 'Practice Yoga',
          description: 'Connect with your body.',
          icon: Icons.self_improvement,
          route: '/yoga',
        );
      case 'laughing':
        return const Recommendation(
          title: 'Laugh a Little',
          description: 'Boost your mood with humor.',
          icon: Icons.emoji_emotions,
          route: '/laughing',
        );
      case 'journaling':
        return const Recommendation(
          title: 'Write in Your Journal',
          description: 'Reflect on your thoughts and feelings.',
          icon: Icons.edit,
          route: '/journal',
        );
      default:
        return const Recommendation(
          title: 'Explore',
          description: 'Discover a new activity.',
          icon: Icons.explore,
          route: '/meditate',
        );
    }
  }
}