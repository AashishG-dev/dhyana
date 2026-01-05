// lib/core/utils/achievement_utils.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/models/achievement_model.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:flutter/material.dart';

class AchievementUtils {
  static List<Achievement> checkAchievements(ProgressDataModel progress) {
    final allAchievements = _getAllAchievements();
    final unlockedAchievements = <Achievement>[];

    for (var achievement in allAchievements) {
      bool isUnlocked = false;
      switch (achievement.name) {
      // Meditation Streak Achievements
        case 'First Step':
          if (progress.meditationStreak >= 1) isUnlocked = true;
          break;
        case 'Consistent Mind':
          if (progress.meditationStreak >= 7) isUnlocked = true;
          break;
        case 'Mindful Habit':
          if (progress.meditationStreak >= 30) isUnlocked = true;
          break;

      // Total Meditation Time Achievements
        case 'Beginner Meditator':
          if (progress.totalMeditationMinutes >= 60) isUnlocked = true;
          break;
        case 'Dedicated Meditator':
          if (progress.totalMeditationMinutes >= 500) isUnlocked = true;
          break;
        case 'Meditation Master':
          if (progress.totalMeditationMinutes >= 1000) isUnlocked = true;
          break;

      // Journaling Achievements
        case 'First Entry':
          if (progress.totalJournalEntries >= 1) isUnlocked = true;
          break;
        case 'Reflective Soul':
          if (progress.totalJournalEntries >= 10) isUnlocked = true;
          break;
        case 'Daily Diarist':
          if (progress.totalJournalEntries >= 50) isUnlocked = true;
          break;
        case 'Journaling Streak':
          if (progress.journalStreak >= 7) isUnlocked = true;
          break;

      // Reading Achievements
        case 'Bookworm':
          if ((progress.totalReadingSeconds / 60).floor() >= 60) {
            isUnlocked = true;
          }
          break;
        case 'Reading Streak':
          if (progress.readingStreak >= 7) isUnlocked = true;
          break;

      // Music Achievements
        case 'Music Lover':
          if ((progress.totalMusicSeconds / 60).floor() >= 60) {
            isUnlocked = true;
          }
          break;
        case 'Music Streak':
          if (progress.musicStreak >= 7) isUnlocked = true;
          break;

      // Yoga Achievements
        case 'Yogi Beginner':
          if (progress.totalYogaMinutes >= 60) isUnlocked = true;
          break;

      // Laughing Therapy Achievements
        case 'Good Laugh':
          if (progress.totalLaughingTherapyMinutes >= 30) isUnlocked = true;
          break;

      // Chatbot Engagement
        case 'AI Companion':
          if (progress.totalChatbotMessages >= 25) isUnlocked = true;
          break;

      // Holistic Wellness
        case 'Well-Rounded':
          if (progress.totalMeditationMinutes > 0 &&
              progress.totalReadingSeconds > 0 &&
              progress.totalMusicSeconds > 0 &&
              progress.totalJournalEntries > 0 &&
              progress.totalYogaMinutes > 0 &&
              progress.totalLaughingTherapyMinutes > 0 &&
              progress.totalChatbotMessages > 0) isUnlocked = true;
          break;
      }

      if (isUnlocked) {
        unlockedAchievements.add(Achievement(
          name: achievement.name,
          description: achievement.description,
          icon: achievement.icon,
          color: achievement.color,
          isUnlocked: true,
        ));
      }
    }
    return unlockedAchievements;
  }

  static List<Achievement> _getAllAchievements() {
    return [
      // Meditation Streak
      Achievement(
          name: 'First Step',
          description: 'Complete your first meditation session.',
          icon: Icons.local_fire_department_outlined,
          color: AppColors.accentPink),
      Achievement(
          name: 'Consistent Mind',
          description: 'Maintain a 7-day meditation streak.',
          icon: Icons.local_fire_department,
          color: AppColors.accentPink),
      Achievement(
          name: 'Mindful Habit',
          description: 'Maintain a 30-day meditation streak.',
          icon: Icons.whatshot,
          color: AppColors.accentPink),

      // Total Meditation Time
      Achievement(
          name: 'Beginner Meditator',
          description: 'Meditate for a total of 60 minutes.',
          icon: Icons.hourglass_bottom,
          color: AppColors.primaryLightGreen),
      Achievement(
          name: 'Dedicated Meditator',
          description: 'Meditate for a total of 500 minutes.',
          icon: Icons.hourglass_top,
          color: AppColors.primaryLightGreen),
      Achievement(
          name: 'Meditation Master',
          description: 'Meditate for a total of 1000 minutes.',
          icon: Icons.hourglass_full,
          color: AppColors.primaryLightGreen),

      // Journaling
      Achievement(
          name: 'First Entry',
          description: 'Write your first journal entry.',
          icon: Icons.edit_note,
          color: AppColors.primaryLightBlue),
      Achievement(
          name: 'Reflective Soul',
          description: 'Write 10 journal entries.',
          icon: Icons.book_outlined,
          color: AppColors.primaryLightBlue),
      Achievement(
          name: 'Daily Diarist',
          description: 'Write 50 journal entries.',
          icon: Icons.auto_stories,
          color: AppColors.primaryLightBlue),
      Achievement(
          name: 'Journaling Streak',
          description: 'Maintain a 7-day journaling streak.',
          icon: Icons.calendar_today,
          color: AppColors.primaryLightBlue),

      // Reading
      Achievement(
          name: 'Bookworm',
          description: 'Read for 60 minutes.',
          icon: Icons.menu_book,
          color: Colors.brown),
      Achievement(
          name: 'Reading Streak',
          description: 'Maintain a 7-day reading streak.',
          icon: Icons.calendar_today,
          color: Colors.brown),

      // Music
      Achievement(
          name: 'Music Lover',
          description: 'Listen to 60 minutes of music.',
          icon: Icons.music_note,
          color: Colors.purple),
      Achievement(
          name: 'Music Streak',
          description: 'Maintain a 7-day music listening streak.',
          icon: Icons.calendar_today,
          color: Colors.purple),

      // Yoga
      Achievement(
          name: 'Yogi Beginner',
          description: 'Complete 60 minutes of yoga.',
          icon: Icons.self_improvement,
          color: Colors.orange),

      // Laughing Therapy
      Achievement(
          name: 'Good Laugh',
          description: 'Enjoy 30 minutes of laughing therapy.',
          icon: Icons.emoji_emotions,
          color: Colors.yellow),

      // Chatbot
      Achievement(
          name: 'AI Companion',
          description: 'Exchange 25 messages with the Dhyana AI.',
          icon: Icons.chat,
          color: Colors.teal),

      // Holistic
      Achievement(
          name: 'Well-Rounded',
          description: 'Try every feature in the app at least once.',
          icon: Icons.star,
          color: Colors.amber),
    ];
  }
}