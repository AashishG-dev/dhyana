// lib/models/yoga_pose_model.dart

class YogaPoseModel {
  final String name;
  final String sanskritName;
  final String description;
  final String imageUrl; // Changed from imageAsset to imageUrl
  final String techniqueUrl;

  const YogaPoseModel({
    required this.name,
    required this.sanskritName,
    required this.description,
    required this.imageUrl, // Changed from imageAsset to imageUrl
    required this.techniqueUrl,
  });
}