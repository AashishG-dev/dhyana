// lib/core/models/progress_data_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion
import 'package:flutter/foundation.dart'; // For debugPrint

/// Defines the data structure for user progress within the Dhyana application.
/// This model will aggregate various metrics related to user engagement,
/// such as total meditation minutes, number of journal entries, and mood trends.
/// It also provides methods for serialization to and from JSON.
class ProgressDataModel {
  final String userId; // The ID of the user this progress data belongs to
  final int totalMeditationMinutes;
  final int meditationStreak; // Consecutive days of meditation
  final int totalJournalEntries;
  final Map<String, int> moodRatingsByDay; // Stores mood ratings for each day (e.g., '2023-10-27': 4)
  final DateTime? lastUpdated;

  /// Constructor for ProgressDataModel.
  ProgressDataModel({
    required this.userId,
    this.totalMeditationMinutes = 0,
    this.meditationStreak = 0,
    this.totalJournalEntries = 0,
    this.moodRatingsByDay = const {},
    this.lastUpdated,
  });

  /// Factory constructor to create a [ProgressDataModel] from a JSON map.
  /// This is used when retrieving progress data from Firestore.
  factory ProgressDataModel.fromJson(Map<String, dynamic> json) {
    return ProgressDataModel(
      userId: json['userId'] as String,
      totalMeditationMinutes: json['totalMeditationMinutes'] as int? ?? 0,
      meditationStreak: json['meditationStreak'] as int? ?? 0,
      totalJournalEntries: json['totalJournalEntries'] as int? ?? 0,
      // Deserialize moodRatingsByDay
      moodRatingsByDay: (json['moodRatingsByDay'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as int)) ??
          const {},
      lastUpdated: (json['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this [ProgressDataModel] instance into a JSON map.
  /// This is used when saving progress data to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalMeditationMinutes': totalMeditationMinutes,
      'meditationStreak': meditationStreak,
      'totalJournalEntries': totalJournalEntries,
      'moodRatingsByDay': moodRatingsByDay,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(), // Use serverTimestamp for updates
    };
  }

  /// Creates a copy of this ProgressDataModel with updated values.
  ProgressDataModel copyWith({
    String? userId,
    int? totalMeditationMinutes,
    int? meditationStreak,
    int? totalJournalEntries,
    Map<String, int>? moodRatingsByDay,
    DateTime? lastUpdated,
  }) {
    return ProgressDataModel(
      userId: userId ?? this.userId,
      totalMeditationMinutes: totalMeditationMinutes ?? this.totalMeditationMinutes,
      meditationStreak: meditationStreak ?? this.meditationStreak,
      totalJournalEntries: totalJournalEntries ?? this.totalJournalEntries,
      moodRatingsByDay: moodRatingsByDay ?? this.moodRatingsByDay,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'ProgressDataModel(userId: $userId, totalMeditationMinutes: $totalMeditationMinutes, meditationStreak: $meditationStreak, totalJournalEntries: $totalJournalEntries, lastUpdated: $lastUpdated)';
  }
}
