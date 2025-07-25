// lib/core/models/stress_relief_exercise_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion
import 'package:flutter/foundation.dart'; // For debugPrint

/// Defines the data structure for a stress relief exercise.
/// This model includes properties like ID, title, description, category,
/// estimated duration, and a Cloudinary URL for a demo video/GIF.
/// It also provides methods for serialization to and from JSON.
class StressReliefExerciseModel {
  final String? id; // Document ID from Firestore
  final String title;
  final String description;
  final String category; // e.g., 'Breathing', 'Movement', 'Grounding'
  final int estimatedDurationMinutes; // Estimated time to complete the exercise
  final String? demoMediaUrl; // Cloudinary URL for a video or GIF demonstration
  final DateTime? createdAt;

  /// Constructor for StressReliefExerciseModel.
  StressReliefExerciseModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedDurationMinutes,
    this.demoMediaUrl,
    this.createdAt,
  });

  /// Factory constructor to create a [StressReliefExerciseModel] from a JSON map.
  /// This is used when retrieving exercise data from Firestore.
  /// [docId] is the Firestore document ID, which becomes the model's ID.
  factory StressReliefExerciseModel.fromJson(Map<String, dynamic> json, String docId) {
    return StressReliefExerciseModel(
      id: docId,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
      demoMediaUrl: json['demoMediaUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this [StressReliefExerciseModel] instance into a JSON map.
  /// This is used when saving exercise data to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'demoMediaUrl': demoMediaUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(), // Use serverTimestamp for new docs
    };
  }

  /// Creates a copy of this StressReliefExerciseModel with updated values.
  StressReliefExerciseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? estimatedDurationMinutes,
    String? demoMediaUrl,
    DateTime? createdAt,
  }) {
    return StressReliefExerciseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      demoMediaUrl: demoMediaUrl ?? this.demoMediaUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'StressReliefExerciseModel(id: $id, title: $title, category: $category, duration: $estimatedDurationMinutes)';
  }
}
