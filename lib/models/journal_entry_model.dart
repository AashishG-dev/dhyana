// lib/core/models/journal_entry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion

/// Defines the data structure for a personal journal entry within the Dhyana application.
class JournalEntryModel {
  final String? id; // Document ID from Firestore (optional for new entries)
  final String userId; // The ID of the user who created this entry
  final String content; // The main text content of the journal entry
  final int moodRating; // A numerical rating for mood (e.g., 1-5, or 1-10)
  final DateTime timestamp; // The date and time the entry was created/last updated
  final String gratitude;
  final String? imageUrl;
  final bool isPinned; // ✅ ADDED: To track pinned status

  /// Constructor for JournalEntryModel.
  JournalEntryModel({
    this.id,
    required this.userId,
    required this.content,
    required this.moodRating,
    required this.timestamp,
    this.gratitude = '',
    this.imageUrl,
    this.isPinned = false, // ✅ ADDED: Default to false
  });

  /// Factory constructor to create a [JournalEntryModel] from a JSON map.
  factory JournalEntryModel.fromJson(Map<String, dynamic> json, String docId) {
    return JournalEntryModel(
      id: docId,
      userId: json['userId'] as String,
      content: json['content'] as String,
      moodRating: json['moodRating'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      gratitude: json['gratitude'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      isPinned: json['isPinned'] as bool? ?? false, // ✅ ADDED: Read from JSON
    );
  }

  /// Converts this [JournalEntryModel] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'moodRating': moodRating,
      'timestamp': Timestamp.fromDate(timestamp),
      'gratitude': gratitude,
      'imageUrl': imageUrl,
      'isPinned': isPinned, // ✅ ADDED: Save to JSON
    };
  }

  /// Creates a copy of this JournalEntryModel with updated values.
  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? content,
    int? moodRating,
    DateTime? timestamp,
    String? gratitude,
    String? imageUrl,
    bool? isPinned, // ✅ ADDED: To copyWith
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      moodRating: moodRating ?? this.moodRating,
      timestamp: timestamp ?? this.timestamp,
      gratitude: gratitude ?? this.gratitude,
      imageUrl: imageUrl ?? this.imageUrl,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  String toString() {
    return 'JournalEntryModel(id: $id, userId: $userId, moodRating: $moodRating, timestamp: $timestamp)';
  }
}