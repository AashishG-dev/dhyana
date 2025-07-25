// lib/core/services/stress_relief_service.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:dhyana/core/services/firestore_service.dart'; // For fetching exercise metadata
import 'package:dhyana/core/services/cloudinary_service.dart'; // For constructing demo URLs
import 'package:dhyana/models/stress_relief_exercise_model.dart'; // For StressReliefExerciseModel

/// Manages fetching stress relief exercises from Firestore and
/// interacting with Cloudinary for their demo media.
/// This service acts as a bridge between the UI/providers and the
/// data sources (Firestore for metadata, Cloudinary for media).
class StressReliefService {
  final FirestoreService _firestoreService;
  final CloudinaryService _cloudinaryService;

  StressReliefService(this._firestoreService, this._cloudinaryService);

  // A simple in-memory cache for stress relief exercises.
  final Map<String, StressReliefExerciseModel> _exerciseCache = {};

  /// Fetches all stress relief exercises from Firestore.
  /// Returns a stream of lists of [StressReliefExerciseModel] to listen for real-time updates.
  Stream<List<StressReliefExerciseModel>> fetchExercises() {
    debugPrint('Fetching all stress relief exercises from Firestore...');
    return _firestoreService.getStressReliefExercises().map((exercises) {
      _exerciseCache.clear();
      for (var exercise in exercises) {
        // ✅ FIX: Add a null check to ensure the exercise ID is not null before caching.
        if (exercise.id != null) {
          _exerciseCache[exercise.id!] = exercise;
        } else {
          debugPrint('Warning: Fetched a stress relief exercise with a null ID. Skipping cache.');
        }
      }
      debugPrint('Loaded and cached ${ _exerciseCache.length } stress relief exercises.');
      return exercises;
    });
  }

  /// Fetches stress relief exercises by category from Firestore.
  /// Returns a stream of lists of [StressReliefExerciseModel].
  Stream<List<StressReliefExerciseModel>> fetchExercisesByCategory(String category) {
    debugPrint('Fetching stress relief exercises by category: $category from Firestore...');
    return _firestoreService.getStressReliefExercisesByCategory(category).map((exercises) {
      debugPrint('Loaded ${exercises.length} stress relief exercises for category: $category.');
      return exercises;
    });
  }

  /// Retrieves a single stress relief exercise by its ID from cache or Firestore.
  Future<StressReliefExerciseModel?> getExerciseById(String exerciseId) async {
    if (_exerciseCache.containsKey(exerciseId)) {
      debugPrint('Returning cached stress relief exercise: $exerciseId');
      return _exerciseCache[exerciseId];
    }
    debugPrint('Fetching stress relief exercise $exerciseId from Firestore...');
    final exercise = await _firestoreService.getStressReliefExerciseById(exerciseId);
    // ✅ FIX: Add a null check here as well for safety before caching.
    if (exercise != null && exercise.id != null) {
      _exerciseCache[exercise.id!] = exercise;
    }
    return exercise;
  }

  /// Constructs the full Cloudinary URL for an exercise demo media.
  String getExerciseDemoUrl(String publicId) {
    return CloudinaryService.buildCloudinaryUrl(
      publicId: publicId,
      resourceType: CloudinaryResourceType.video,
    );
  }

  /// Clears the in-memory cache of exercises.
  void clearCache() {
    _exerciseCache.clear();
    debugPrint('Stress relief exercise cache cleared.');
  }
}