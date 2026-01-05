// lib/core/utils/gamification_utils.dart
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/models/task_model.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:flutter/material.dart';

class Level {
  final int levelNumber;
  final String title;
  final String description;
  final int gemsRequired;
  final List<Task> tasks;

  Level({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.gemsRequired,
    required this.tasks,
  });
}

class UserLevelProgress {
  final Level currentLevel;
  final Level nextLevel;
  final int currentGems;
  final double progressPercentage; // 0.0 to 1.0

  UserLevelProgress({
    required this.currentLevel,
    required this.nextLevel,
    required this.currentGems,
    required this.progressPercentage,
  });
}

class GamificationUtils {
  static final List<Level> allLevels = [
    Level(
        levelNumber: 1,
        title: 'Initiate',
        description: 'Begin your journey by setting up your profile.',
        gemsRequired: 0,
        tasks: [
          Task(
            id: 'complete_profile',
            title: 'Complete Your Profile',
            description:
            'Set your mindfulness goals to personalize your journey.',
            icon: Icons.person,
            navigationPath: '/edit-profile',
          ),
        ]),
    Level(
        levelNumber: 2,
        title: 'Seeker',
        description: 'Explore the core practices of mindfulness.',
        gemsRequired: 100,
        tasks: [
          Task(
            id: 'practice_breathing',
            title: 'Practice Breathing',
            description: 'Complete one guided breathing session.',
            icon: Icons.air,
            navigationPath: '/meditate/breathing',
          ),
          Task(
            id: 'read_article',
            title: 'Read an Article',
            description: 'Read one article to learn more about mindfulness.',
            icon: Icons.auto_stories,
            navigationPath: '/reading-therapy',
          ),
          Task(
            id: 'write_journal',
            title: 'Write a Journal Entry',
            description: 'Reflect on your day and track your mood.',
            icon: Icons.edit,
            navigationPath: '/journal',
          ),
        ]),
    Level(
        levelNumber: 3,
        title: 'Apprentice',
        description: 'You\'re starting to build a consistent routine.',
        gemsRequired: 250,
        tasks: [
          Task(
            id: 'listen_music',
            title: 'Listen to Music',
            description: 'Listen to 15 minutes of calming music.',
            icon: Icons.music_note,
            navigationPath: '/music-therapy',
            minutesRequired: 15,
          ),
          Task(
            id: 'laugh_therapy',
            title: 'Laugh a Little',
            description:
            'Watch a stand-up video in the laughing therapy section.',
            icon: Icons.emoji_emotions,
            navigationPath: '/laughing',
          ),
        ]),
    Level(
        levelNumber: 4,
        title: 'Adept',
        description: 'Develop a strong and consistent mindfulness habit.',
        gemsRequired: 500,
        tasks: [
          Task(
            id: 'try_yoga',
            title: 'Try Yoga',
            description: 'Complete a 15-minute yoga session.',
            icon: Icons.self_improvement,
            navigationPath: '/yoga',
            minutesRequired: 15,
          ),
          Task(
            id: 'talk_to_dhyana',
            title: 'Talk to Dhyana',
            description: 'Have a conversation with the Dhyana AI.',
            icon: Icons.chat,
            navigationPath: '/chatbot',
          ),
        ]),
    Level(
        levelNumber: 5,
        title: 'Practitioner',
        description: 'Mindfulness is becoming a natural part of your day.',
        gemsRequired: 1000,
        tasks: [
          Task(
            id: 'meditate_30',
            title: '30-Minute Meditation',
            description: 'Complete a 30-minute guided meditation.',
            icon: Icons.spa,
            navigationPath: '/meditate',
            minutesRequired: 30,
          ),
          Task(
            id: 'read_3_articles',
            title: 'Read 3 Articles',
            description: 'Expand your knowledge by reading three articles.',
            icon: Icons.library_books,
            navigationPath: '/reading-therapy',
          ),
        ]),
    Level(
        levelNumber: 6,
        title: 'Master',
        description: 'Integrate mindfulness deeply into your daily life.',
        gemsRequired: 1500,
        tasks: [
          Task(
            id: '7_day_streak',
            title: '7-Day Streak',
            description: 'Maintain a 7-day meditation streak.',
            icon: Icons.local_fire_department,
            navigationPath: '/progress',
          ),
          Task(
            id: 'journal_7_days',
            title: 'Journal for 7 Days',
            description: 'Write in your journal for seven consecutive days.',
            icon: Icons.calendar_today,
            navigationPath: '/journal',
          ),
        ]),

    // --- NEW LEVELS START HERE ---

    Level(
        levelNumber: 7,
        title: 'Virtuoso',
        description: 'Explore the full spectrum of therapies available.',
        gemsRequired: 2500,
        tasks: [
          Task(
            id: 'save_article_offline',
            title: 'Save for Later',
            description: 'Save an article for offline reading.',
            icon: Icons.bookmark_add,
            navigationPath: '/reading-therapy',
          ),
          Task(
            id: 'explore_memes',
            title: 'Meme Explorer',
            description: 'Explore the meme feed in the Laughing Therapy section.',
            icon: Icons.burst_mode,
            navigationPath: '/laughing/memes',
          ),
        ]),
    Level(
        levelNumber: 8,
        title: 'Savant',
        description: 'Deepen your practice and build resilience.',
        gemsRequired: 4000,
        tasks: [
          Task(
            id: 'download_music',
            title: 'Offline Harmony',
            description: 'Download a music track for offline listening.',
            icon: Icons.download_for_offline,
            navigationPath: '/music-therapy',
          ),
          Task(
            id: 'yoga_technique',
            title: 'Learn a Pose',
            description: 'Learn the technique for a yoga asana.',
            icon: Icons.menu_book,
            navigationPath: '/yoga',
          ),
        ]),
    Level(
        levelNumber: 9,
        title: 'Guide',
        description: 'Your consistency is creating lasting change.',
        gemsRequired: 6000,
        tasks: [
          Task(
            id: 'music_streak_7',
            title: 'Musical Week',
            description: 'Maintain a 7-day music listening streak.',
            icon: Icons.music_note,
            navigationPath: '/progress',
          ),
          Task(
            id: 'reading_streak_7',
            title: 'Avid Reader',
            description: 'Maintain a 7-day reading streak.',
            icon: Icons.auto_stories,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 10,
        title: 'Guru',
        description: 'You are a beacon of calm and mindfulness.',
        gemsRequired: 8500,
        tasks: [
          Task(
            id: 'meditation_streak_14',
            title: 'Mindful Fortnight',
            description: 'Maintain a 14-day meditation streak.',
            icon: Icons.whatshot,
            navigationPath: '/progress',
          ),
          Task(
            id: 'holistic_day',
            title: 'Holistic Day',
            description: 'Use Breathing, Reading, and Music in a single day.',
            icon: Icons.all_inclusive,
            navigationPath: '/home',
          ),
        ]),
    Level(
        levelNumber: 11,
        title: 'Ascetic',
        description: 'Discipline and practice have become second nature.',
        gemsRequired: 11000,
        tasks: [
          Task(
            id: 'total_yoga_60',
            title: 'Yoga Apprentice',
            description: 'Complete a total of 60 minutes of yoga.',
            icon: Icons.self_improvement,
            navigationPath: '/progress',
          ),
          Task(
            id: 'total_music_120',
            title: 'Sound Scape Explorer',
            description: 'Listen to a total of 120 minutes of music.',
            icon: Icons.headset_mic,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 12,
        title: 'Sage',
        description: 'Your wisdom grows with each mindful moment.',
        gemsRequired: 14000,
        tasks: [
          Task(
            id: 'journal_streak_14',
            title: 'Reflective Fortnight',
            description: 'Maintain a 14-day journaling streak.',
            icon: Icons.edit_calendar,
            navigationPath: '/progress',
          ),
          Task(
            id: 'chatbot_25',
            title: 'AI Companion',
            description: 'Exchange 25 messages with the Dhyana AI.',
            icon: Icons.smart_toy,
            navigationPath: '/chatbot',
          ),
        ]),
    Level(
        levelNumber: 13,
        title: 'Oracle',
        description: 'You find clarity and insight in your daily practice.',
        gemsRequired: 17500,
        tasks: [
          Task(
            id: 'total_reading_180',
            title: 'Well-Read',
            description: 'Read for a total of 3 hours (180 minutes).',
            icon: Icons.library_books,
            navigationPath: '/progress',
          ),
          Task(
            id: 'total_laughing_60',
            title: 'Humor Heals',
            description: 'Enjoy 60 minutes of Laughing Therapy.',
            icon: Icons.sentiment_very_satisfied,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 14,
        title: 'Mystic',
        description: 'You are deeply connected to your inner self.',
        gemsRequired: 21500,
        tasks: [
          Task(
            id: 'meditation_streak_30',
            title: 'Mindful Month',
            description: 'Maintain a 30-day meditation streak.',
            icon: Icons.celebration,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 15,
        title: 'Harmonizer',
        description: 'You skillfully balance all aspects of your wellbeing.',
        gemsRequired: 26000,
        tasks: [
          Task(
            id: 'holistic_week',
            title: 'Holistic Week',
            description: 'Maintain a 7-day streak for Meditation, Reading, and Journaling simultaneously.',
            icon: Icons.workspace_premium,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 16,
        title: 'Tranquil Soul',
        description: 'Inner peace is your constant companion.',
        gemsRequired: 31000,
        tasks: [
          Task(
            id: 'total_meditation_500',
            title: '500 Minutes of Calm',
            description: 'Meditate for a total of 500 minutes.',
            icon: Icons.spa,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 17,
        title: 'Zen Master',
        description: 'You navigate life with grace and ease.',
        gemsRequired: 37000,
        tasks: [
          Task(
            id: 'total_journal_50',
            title: 'The Diarist',
            description: 'Write a total of 50 journal entries.',
            icon: Icons.history_edu,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 18,
        title: 'Enlightened One',
        description: 'Your practice illuminates your path and inspires others.',
        gemsRequired: 44000,
        tasks: [
          Task(
            id: 'meditation_streak_60',
            title: 'Two Mindful Months',
            description: 'Maintain a 60-day meditation streak.',
            icon: Icons.auto_awesome,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 19,
        title: 'Bodhisattva',
        description: 'Your compassion and mindfulness benefit all beings.',
        gemsRequired: 52000,
        tasks: [
          Task(
            id: 'total_meditation_1000',
            title: '1000 Minutes of Peace',
            description: 'Meditate for a total of 1000 minutes.',
            icon: Icons.self_improvement,
            navigationPath: '/progress',
          ),
        ]),
    Level(
        levelNumber: 20,
        title: 'Nirvana',
        description: 'You have achieved a state of profound peace and understanding.',
        gemsRequired: 65000,
        tasks: [
          Task(
            id: 'all_features_mastered',
            title: 'Dhyana Master',
            description: 'Achieve a 14-day streak in Meditation, Journaling, Reading, and Music.',
            icon: Icons.military_tech,
            navigationPath: '/progress',
          ),
        ]),
  ];

  static int calculateTotalGems(ProgressDataModel progress) {
    int gems = 0;
    gems += progress.totalMeditationMinutes * 10;
    gems += (progress.totalReadingSeconds / 60).floor() * 15;
    gems += (progress.totalMusicSeconds / 60).floor() * 10;
    gems += progress.totalJournalEntries * 50;
    gems += progress.totalChatbotMessages * 5;
    gems += progress.meditationStreak * 100;
    gems += progress.totalYogaMinutes * 15;
    gems += progress.totalLaughingTherapyMinutes * 10;
    return gems;
  }

  static UserLevelProgress getUserLevelProgress(
      UserModel user, ProgressDataModel progress) {
    int totalGems = calculateTotalGems(progress);

    Level currentLevel = allLevels.lastWhere(
            (level) => totalGems >= level.gemsRequired,
        orElse: () => allLevels.first);

    Level nextLevel = allLevels.firstWhere(
            (level) => level.levelNumber == currentLevel.levelNumber + 1,
        orElse: () => currentLevel);

    if (currentLevel.levelNumber == nextLevel.levelNumber) {
      return UserLevelProgress(
        currentLevel: currentLevel,
        nextLevel: nextLevel,
        currentGems: totalGems,
        progressPercentage: 1.0,
      );
    }

    final gemsInCurrentLevel = totalGems - currentLevel.gemsRequired;
    final gemsForNextLevel =
        nextLevel.gemsRequired - currentLevel.gemsRequired;
    final double progressPercentage = (gemsForNextLevel > 0)
        ? (gemsInCurrentLevel / gemsForNextLevel).clamp(0.0, 1.0)
        : 1.0;

    return UserLevelProgress(
      currentLevel: currentLevel,
      nextLevel: nextLevel,
      currentGems: totalGems,
      progressPercentage: progressPercentage,
    );
  }
}