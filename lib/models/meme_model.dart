// lib/models/meme_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MemeModel {
  final String? id; // Document ID from Firestore
  final String imageUrl;
  final String? caption;
  final DateTime? createdAt;

  const MemeModel({
    this.id,
    required this.imageUrl,
    this.caption,
    this.createdAt,
  });

  // fromJson factory to create a MemeModel from a Firestore document
  factory MemeModel.fromJson(Map<String, dynamic> json, String docId) {
    return MemeModel(
      id: docId,
      imageUrl: json['imageUrl'] as String,
      caption: json['caption'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // toJson method to convert a MemeModel to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}