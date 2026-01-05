// lib/core/models/meditation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MeditationModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final int durationMinutes;
  final String? audioFilePath;
  final String? imageUrl;
  final DateTime? createdAt;
  final String voiceType;
  final int playCount;
  final String? localAudioPath; // New field for the local audio file

  MeditationModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationMinutes,
    this.audioFilePath,
    this.imageUrl,
    this.createdAt,
    this.voiceType = 'Female',
    this.playCount = 0,
    this.localAudioPath, // Added to constructor
  });

  // ✅ FIX: Added fallback values for all required fields to prevent crashes from null data.
  factory MeditationModel.fromJson(Map<String, dynamic> json, String docId) {
    return MeditationModel(
      id: docId,
      title: json['title'] as String? ?? 'Untitled Meditation',
      description:
      json['description'] as String? ?? 'No description available.',
      category: json['category'] as String? ?? 'General',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      audioFilePath: json['audioFilePath'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      voiceType: json['voiceType'] as String? ?? 'Female',
      playCount: json['playCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'durationMinutes': durationMinutes,
      'audioFilePath': audioFilePath,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'voiceType': voiceType,
      'playCount': playCount,
    };
  }

  MeditationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? durationMinutes,
    String? audioFilePath,
    String? imageUrl,
    DateTime? createdAt,
    String? voiceType,
    int? playCount,
    String? localAudioPath,
  }) {
    return MeditationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      voiceType: voiceType ?? this.voiceType,
      playCount: playCount ?? this.playCount,
      localAudioPath: localAudioPath ?? this.localAudioPath,
    );
  }

  @override
  String toString() {
    return 'MeditationModel(id: $id, title: $title, category: $category, durationMinutes: $durationMinutes, voiceType: $voiceType, playCount: $playCount)';
  }
}