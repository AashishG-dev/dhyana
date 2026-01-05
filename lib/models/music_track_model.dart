// lib/models/music_track_model.dart

class MusicTrackModel {
  final String id;
  final String title;
  final String artist;
  final int durationSeconds;
  final String? imageUrl; // Made nullable to handle offline tracks
  final String audioUrl;
  final String? localImagePath; // New field for the local image file

  MusicTrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.durationSeconds,
    this.imageUrl, // No longer required
    required this.audioUrl,
    this.localImagePath, // Added to constructor
  });

  /// ✅ UPDATED: Factory constructor now forces HTTPS on the audio URL.
  factory MusicTrackModel.fromJamendoJson(Map<String, dynamic> json) {
    return MusicTrackModel(
      id: json['id'] as String? ?? '',
      title: json['name'] as String? ?? 'Untitled Track',
      artist: json['artist_name'] as String? ?? 'Unknown Artist',
      durationSeconds: json['duration'] as int? ?? 0,
      // Also force HTTPS on the image URL as a good practice
      imageUrl: (json['album_image'] as String? ?? 'https://placehold.co/600x400?text=No+Image').replaceFirst('http://', 'https://'),
      // Force the audio URL to use HTTPS to avoid Android network security issues
      audioUrl: (json['audio'] as String? ?? '').replaceFirst('http://', 'https://'),
    );
  }
}