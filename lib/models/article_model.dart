// lib/core/models/article_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion
import 'package:flutter/foundation.dart'; // For debugPrint

/// Defines the data structure for an educational article within the Dhyana application.
/// This model includes properties like ID, title, category, image URL,
/// reading time, and author. It also provides methods for serialization
/// to and from JSON.
class ArticleModel {
  final String? id; // Document ID from Firestore
  final String title;
  final String category; // e.g., 'Mindfulness', 'Stress Management', 'Well-being'
  final String? imageUrl; // Cloudinary URL for the article's thumbnail image
  final int readingTimeMinutes; // Estimated reading time in minutes
  final String author;
  final DateTime? publishedAt; // Timestamp of when the article was published

  /// Constructor for ArticleModel.
  ArticleModel({
    this.id,
    required this.title,
    required this.category,
    this.imageUrl,
    required this.readingTimeMinutes,
    required this.author,
    this.publishedAt,
  });

  /// Factory constructor to create an [ArticleModel] from a JSON map.
  /// This is used when retrieving article metadata from Firestore.
  /// [docId] is the Firestore document ID, which becomes the model's ID.
  factory ArticleModel.fromJson(Map<String, dynamic> json, String docId) {
    return ArticleModel(
      id: docId,
      title: json['title'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      readingTimeMinutes: json['readingTimeMinutes'] as int,
      author: json['author'] as String,
      publishedAt: (json['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this [ArticleModel] instance into a JSON map.
  /// This is used when saving article metadata to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'readingTimeMinutes': readingTimeMinutes,
      'author': author,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : FieldValue.serverTimestamp(), // Use serverTimestamp for new docs
    };
  }

  /// Creates a copy of this ArticleModel with updated values.
  ArticleModel copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    int? readingTimeMinutes,
    String? author,
    DateTime? publishedAt,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  String toString() {
    return 'ArticleModel(id: $id, title: $title, category: $category, readingTimeMinutes: $readingTimeMinutes)';
  }
}
