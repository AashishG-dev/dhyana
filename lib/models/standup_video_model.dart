// lib/models/standup_video_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StandupVideoModel {
  final String? id; // Document ID from Firestore
  final String title;
  final String artist;
  final String videoId;
  final String thumbnailUrl;
  final DateTime? createdAt;

  const StandupVideoModel({
    this.id,
    required this.title,
    required this.artist,
    required this.videoId,
    required this.thumbnailUrl,
    this.createdAt,
  });

  // fromJson factory
  factory StandupVideoModel.fromJson(Map<String, dynamic> json, String docId) {
    return StandupVideoModel(
      id: docId,
      title: json['title'] as String,
      artist: json['artist'] as String,
      videoId: json['videoId'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'videoId': videoId,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}