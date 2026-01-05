// lib/models/yoga_video_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class YogaVideoModel {
  final String? id; // ✅ ADDED: Document ID from Firestore
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoId;

  const YogaVideoModel({
    this.id, // ✅ ADDED: id to constructor
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoId,
  });

  // ✅ ADDED: Factory constructor to create from a Firestore document
  factory YogaVideoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return YogaVideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoId: data['videoId'] ?? '',
    );
  }

  // ✅ ADDED: Method to convert to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoId': videoId,
    };
  }
}