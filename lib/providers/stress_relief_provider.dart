// lib/core/providers/stress_relief_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:dhyana/core/services/stress_relief_service.dart'; // Import StressReliefService
import 'package:dhyana/models/stress_relief_exercise_model.dart'; // Import StressReliefExerciseModel
import 'package:dhyana/providers/auth_provider.dart'; // To access firestoreServiceProvider and cloudinaryServiceProvider

/// Provides an instance of [StressReliefService].
/// It depends on [firestoreServiceProvider] and [cloudinaryServiceProvider].
final stressReliefServiceProvider = Provider<StressReliefService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final cloudinaryService = ref.watch(cloudinaryServiceProvider);
  return StressReliefService(firestoreService, cloudinaryService);
});

/// Provides a stream of all [StressReliefExerciseModel]s from Firestore.
final stressReliefExercisesProvider =
StreamProvider<List<StressReliefExerciseModel>>((ref) {
  final stressReliefService = ref.watch(stressReliefServiceProvider);
  debugPrint('Fetching all stress relief exercises from Firestore.');
  return stressReliefService.fetchExercises();
});

/// Provides a stream of [StressReliefExerciseModel]s filtered by category.
/// This is a family provider to fetch exercises for a specific category.
final stressReliefExercisesByCategoryProvider =
StreamProvider.family<List<StressReliefExerciseModel>, String>((ref, category) {
  final stressReliefService = ref.watch(stressReliefServiceProvider);
  debugPrint('Fetching stress relief exercises for category: $category');
  return stressReliefService.fetchExercisesByCategory(category);
});

/// Provides a specific [StressReliefExerciseModel] by its ID.
/// This is a FutureProvider as it fetches a single item once.
final stressReliefExerciseByIdProvider =
FutureProvider.family<StressReliefExerciseModel?, String>((ref, exerciseId) async {
  final stressReliefService = ref.watch(stressReliefServiceProvider);
  return await stressReliefService.getExerciseById(exerciseId);
});
