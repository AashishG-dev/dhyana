// lib/models/progress_data_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';


// ✅ ADDED: Helper class is now defined here to avoid circular dependencies.
class MindfulnessLevel {
  final String name;
  final double progress; // 0.0 to 1.0
  final int pointsToNextLevel;

  MindfulnessLevel({
    required this.name,
    required this.progress,
    required this.pointsToNextLevel,
  });
}

/// Defines the data structure for user progress within the Dhyana application.
class ProgressDataModel {
  final String userId;
  final int totalMeditationMinutes;
  final int meditationStreak;
  final int totalJournalEntries;
  final int totalReadingSeconds;
  final int totalMusicSeconds;
  final int totalChatbotMessages;
  final Map<String, int> moodRatingsByDay;
  final DateTime? lastUpdated;
  final int totalYogaMinutes;
  final int totalLaughingTherapyMinutes;

  // ✅ ADDED: New fields for multi-feature streaks
  final int journalStreak;
  final int readingStreak;
  final int musicStreak;
  final DateTime? lastMeditationDate;
  final DateTime? lastJournalDate;
  final DateTime? lastReadingDate;
  final DateTime? lastMusicDate;

  ProgressDataModel({
    required this.userId,
    this.totalMeditationMinutes = 0,
    this.meditationStreak = 0,
    this.totalJournalEntries = 0,
    this.totalReadingSeconds = 0,
    this.totalMusicSeconds = 0,
    this.totalChatbotMessages = 0,
    this.moodRatingsByDay = const {},
    this.lastUpdated,
    this.totalYogaMinutes = 0,
    this.totalLaughingTherapyMinutes = 0,
    // ✅ ADDED: Initialize new fields
    this.journalStreak = 0,
    this.readingStreak = 0,
    this.musicStreak = 0,
    this.lastMeditationDate,
    this.lastJournalDate,
    this.lastReadingDate,
    this.lastMusicDate,
  });

  /// Getter to calculate the user's level based on all progress.
  MindfulnessLevel get mindfulnessLevel {
    final int meditationPoints = totalMeditationMinutes;
    final int readingPoints = (totalReadingSeconds / 60).floor();
    final int musicPoints = (totalMusicSeconds / 60).floor();
    final int journalPoints = totalJournalEntries * 5;
    final int chatbotPoints = totalChatbotMessages * 2;
    final int streakBonus = meditationStreak * 10;
    final int yogaPoints = totalYogaMinutes * 2;
    final int laughingPoints = totalLaughingTherapyMinutes;

    final totalPoints = meditationPoints +
        readingPoints +
        musicPoints +
        journalPoints +
        chatbotPoints +
        streakBonus +
        yogaPoints +
        laughingPoints;

    const levels = {
      5000: 'Master',
      2500: 'Adept',
      1000: 'Apprentice',
      200: 'Novice',
      0: 'Beginner',
    };

    String currentLevelName = 'Beginner';
    int currentLevelThreshold = 0;
    int nextLevelThreshold = 200;

    for (var threshold in levels.keys.toList()..sort((a, b) => b.compareTo(a))) {
      if (totalPoints >= threshold) {
        currentLevelName = levels[threshold]!;
        currentLevelThreshold = threshold;
        nextLevelThreshold = levels.keys
            .lastWhere((t) => t > threshold, orElse: () => threshold + 2000);
        break;
      }
    }

    final pointsInCurrentLevel = totalPoints - currentLevelThreshold;
    final pointsForNextLevel = nextLevelThreshold - currentLevelThreshold;
    final double progress = (pointsForNextLevel > 0)
        ? (pointsInCurrentLevel / pointsForNextLevel).clamp(0.0, 1.0)
        : 1.0;

    return MindfulnessLevel(
      name: currentLevelName,
      progress: progress,
      pointsToNextLevel:
      (pointsForNextLevel - pointsInCurrentLevel).clamp(0, 99999),
    );
  }

  factory ProgressDataModel.fromJson(Map<String, dynamic> json) {
    return ProgressDataModel(
      userId: json['userId'] as String,
      totalMeditationMinutes: json['totalMeditationMinutes'] as int? ?? 0,
      meditationStreak: json['meditationStreak'] as int? ?? 0,
      totalJournalEntries: json['totalJournalEntries'] as int? ?? 0,
      totalReadingSeconds: json['totalReadingSeconds'] as int? ?? 0,
      totalMusicSeconds: json['totalMusicSeconds'] as int? ?? 0,
      totalChatbotMessages: json['totalChatbotMessages'] as int? ?? 0,
      moodRatingsByDay: (json['moodRatingsByDay'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as int)) ??
          const {},
      lastUpdated: (json['lastUpdated'] as Timestamp?)?.toDate(),
      totalYogaMinutes: json['totalYogaMinutes'] as int? ?? 0,
      totalLaughingTherapyMinutes:
      json['totalLaughingTherapyMinutes'] as int? ?? 0,
      journalStreak: json['journalStreak'] as int? ?? 0,
      readingStreak: json['readingStreak'] as int? ?? 0,
      musicStreak: json['musicStreak'] as int? ?? 0,
      lastMeditationDate: (json['lastMeditationDate'] as Timestamp?)?.toDate(),
      lastJournalDate: (json['lastJournalDate'] as Timestamp?)?.toDate(),
      lastReadingDate: (json['lastReadingDate'] as Timestamp?)?.toDate(),
      lastMusicDate: (json['lastMusicDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalMeditationMinutes': totalMeditationMinutes,
      'meditationStreak': meditationStreak,
      'totalJournalEntries': totalJournalEntries,
      'totalReadingSeconds': totalReadingSeconds,
      'totalMusicSeconds': totalMusicSeconds,
      'totalChatbotMessages': totalChatbotMessages,
      'moodRatingsByDay': moodRatingsByDay,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : FieldValue.serverTimestamp(),
      'totalYogaMinutes': totalYogaMinutes,
      'totalLaughingTherapyMinutes': totalLaughingTherapyMinutes,
      'journalStreak': journalStreak,
      'readingStreak': readingStreak,
      'musicStreak': musicStreak,
      'lastMeditationDate': lastMeditationDate != null
          ? Timestamp.fromDate(lastMeditationDate!)
          : null,
      'lastJournalDate':
      lastJournalDate != null ? Timestamp.fromDate(lastJournalDate!) : null,
      'lastReadingDate':
      lastReadingDate != null ? Timestamp.fromDate(lastReadingDate!) : null,
      'lastMusicDate':
      lastMusicDate != null ? Timestamp.fromDate(lastMusicDate!) : null,
    };
  }

  ProgressDataModel copyWith({
    String? userId,
    int? totalMeditationMinutes,
    int? meditationStreak,
    int? totalJournalEntries,
    int? totalReadingSeconds,
    int? totalMusicSeconds,
    int? totalChatbotMessages,
    Map<String, int>? moodRatingsByDay,
    DateTime? lastUpdated,
    int? totalYogaMinutes,
    int? totalLaughingTherapyMinutes,
    int? journalStreak,
    int? readingStreak,
    int? musicStreak,
    DateTime? lastMeditationDate,
    DateTime? lastJournalDate,
    DateTime? lastReadingDate,
    DateTime? lastMusicDate,
  }) {
    return ProgressDataModel(
      userId: userId ?? this.userId,
      totalMeditationMinutes:
      totalMeditationMinutes ?? this.totalMeditationMinutes,
      meditationStreak: meditationStreak ?? this.meditationStreak,
      totalJournalEntries: totalJournalEntries ?? this.totalJournalEntries,
      totalReadingSeconds: totalReadingSeconds ?? this.totalReadingSeconds,
      totalMusicSeconds: totalMusicSeconds ?? this.totalMusicSeconds,
      totalChatbotMessages: totalChatbotMessages ?? this.totalChatbotMessages,
      moodRatingsByDay: moodRatingsByDay ?? this.moodRatingsByDay,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalYogaMinutes: totalYogaMinutes ?? this.totalYogaMinutes,
      totalLaughingTherapyMinutes:
      totalLaughingTherapyMinutes ?? this.totalLaughingTherapyMinutes,
      journalStreak: journalStreak ?? this.journalStreak,
      readingStreak: readingStreak ?? this.readingStreak,
      musicStreak: musicStreak ?? this.musicStreak,
      lastMeditationDate: lastMeditationDate ?? this.lastMeditationDate,
      lastJournalDate: lastJournalDate ?? this.lastJournalDate,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      lastMusicDate: lastMusicDate ?? this.lastMusicDate,
    );
  }

  @override
  String toString() {
    return 'ProgressDataModel(userId: $userId, totalMeditationMinutes: $totalMeditationMinutes, streak: $meditationStreak)';
  }
}