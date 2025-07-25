// lib/core/models/journal_entry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion
import 'package:flutter/foundation.dart'; // For debugPrint

/// Defines the data structure for a personal journal entry within the Dhyana application.
/// This model includes properties like ID, user ID, content, mood rating,
/// and a timestamp. It also provides methods for serialization to and from JSON.
class JournalEntryModel {
  final String? id; // Document ID from Firestore (optional for new entries)
  final String userId; // The ID of the user who created this entry
  final String content; // The main text content of the journal entry
  final int moodRating; // A numerical rating for mood (e.g., 1-5, or 1-10)
  final DateTime timestamp; // The date and time the entry was created/last updated

  /// Constructor for JournalEntryModel.
  JournalEntryModel({
    this.id,
    required this.userId,
    required this.content,
    required this.moodRating,
    required this.timestamp,
  });

  /// Factory constructor to create a [JournalEntryModel] from a JSON map.
  /// This is used when retrieving journal entries from Firestore.
  /// [docId] is the Firestore document ID, which becomes the model's ID.
  factory JournalEntryModel.fromJson(Map<String, dynamic> json, String docId) {
    return JournalEntryModel(
      id: docId,
      userId: json['userId'] as String,
      content: json['content'] as String,
      moodRating: json['moodRating'] as int,
      // Convert Firestore Timestamp to DateTime
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Converts this [JournalEntryModel] instance into a JSON map.
  /// This is used when saving journal entries to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'moodRating': moodRating,
      // Convert DateTime to Firestore Timestamp
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Creates a copy of this JournalEntryModel with updated values.
  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? content,
    int? moodRating,
    DateTime? timestamp,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      moodRating: moodRating ?? this.moodRating,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'JournalEntryModel(id: $id, userId: $userId, moodRating: $moodRating, timestamp: $timestamp)';
  }
}
