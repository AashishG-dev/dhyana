// lib/models/feedback_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String? id;
  final String userId;
  final String type;
  final String message;
  final DateTime timestamp;
  final String? imageUrl;

  FeedbackModel({
    this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.imageUrl,
  });

  // ✅ FIXED: Added a factory constructor to correctly parse the imageUrl
  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
    };
  }
}