// lib/core/providers/progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/providers/auth_provider.dart';

final userProgressDataProvider =
StreamProvider.family<ProgressDataModel?, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  debugPrint('Fetching progress data for user: $userId');
  return firestoreService.getProgressData(userId);
});

class ProgressNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final Ref _ref;

  ProgressNotifier(this._firestoreService, this._ref) : super(const AsyncValue.data(null));

  Future<void> saveProgressData(String userId, ProgressDataModel data) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.saveProgressData(userId, data);
      state = const AsyncValue.data(null);
      debugPrint('Progress data saved successfully for user: $userId');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      debugPrint('Error saving progress data for user $userId: $e');
    }
  }

  // ✅ ADD: New method to log a breathing session.
  Future<void> logBreathingSession(String userId, int durationMinutes) async {
    state = const AsyncValue.loading();
    try {
      final currentProgress = await _ref.read(userProgressDataProvider(userId).future);

      final updatedProgress = (currentProgress ?? ProgressDataModel(userId: userId)).copyWith(
        totalMeditationMinutes: (currentProgress?.totalMeditationMinutes ?? 0) + durationMinutes,
        // We can add more sophisticated streak logic here later
        meditationStreak: (currentProgress?.meditationStreak ?? 0) + 1,
        lastUpdated: DateTime.now(),
      );

      await _firestoreService.saveProgressData(userId, updatedProgress);
      _ref.invalidate(userProgressDataProvider(userId)); // Refresh the provider
      state = const AsyncValue.data(null);
      debugPrint('Breathing session of $durationMinutes minutes logged for user: $userId');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final progressNotifierProvider =
StateNotifierProvider<ProgressNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ProgressNotifier(firestoreService, ref);
});