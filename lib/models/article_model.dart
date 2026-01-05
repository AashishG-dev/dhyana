// lib/models/article_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ArticleModel {
  final String? id;
  final String title;
  final String category;
  final String? imageUrl;
  final int readingTimeMinutes;
  final String author;
  final DateTime? publishedAt;
  // ✅ ADDED: The main content of the article
  final String? content;

  ArticleModel({
    this.id,
    required this.title,
    required this.category,
    this.imageUrl,
    required this.readingTimeMinutes,
    required this.author,
    this.publishedAt,
    // ✅ ADDED: Initialize in constructor
    this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json, String docId) {
    return ArticleModel(
      id: docId,
      title: json['title'] as String? ?? 'Untitled Article',
      category: json['category'] as String? ?? 'General',
      imageUrl: json['imageUrl'] as String?,
      readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 0,
      author: json['author'] as String? ?? 'Unknown Author',
      publishedAt: (json['publishedAt'] as Timestamp?)?.toDate(),
      // ✅ ADDED: Deserialize from JSON
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'readingTimeMinutes': readingTimeMinutes,
      'author': author,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : FieldValue.serverTimestamp(),
      // ✅ ADDED: Serialize to JSON
      'content': content,
    };
  }

  ArticleModel copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    int? readingTimeMinutes,
    String? author,
    DateTime? publishedAt,
    // ✅ ADDED: Include in copyWith
    String? content,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      // ✅ ADDED: Handle in copyWith
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    return 'ArticleModel(id: $id, title: $title, category: $category, readingTimeMinutes: $readingTimeMinutes)';
  }
}