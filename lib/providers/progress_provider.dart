// lib/providers/progress_provider.dart
import 'package:dhyana/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/providers/auth_provider.dart';

const String _guestProgressKey = 'guest_progress_data';

final userProgressDataProvider =
StreamProvider.family<ProgressDataModel?, String>((ref, userId) {
  if (userId == 'guest') {
    return Stream.value(ref.watch(guestProgressProvider));
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  debugPrint('Fetching progress data for user: $userId');
  return firestoreService.getProgressData(userId);
});

final guestProgressProvider = StateProvider<ProgressDataModel?>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final json = storageService.getJson(_guestProgressKey);
  if (json != null) {
    return ProgressDataModel.fromJson(json);
  }
  return ProgressDataModel(userId: 'guest');
});

class ProgressNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final Ref _ref;

  ProgressNotifier(this._firestoreService, this._storageService, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> _updateGuestProgress(
      ProgressDataModel Function(ProgressDataModel) updater) async {
    state = const AsyncValue.loading();
    try {
      final currentProgress =
          _ref.read(guestProgressProvider) ?? ProgressDataModel(userId: 'guest');
      final updatedProgress = updater(currentProgress);
      await _storageService.saveJson(
          _guestProgressKey, updatedProgress.toJson());
      _ref.read(guestProgressProvider.notifier).state = updatedProgress;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _updateFirestoreProgress(
      String userId, ProgressDataModel Function(ProgressDataModel) updater) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService
          .updateProgressDataInTransaction(userId, (currentProgress) {
        return updater(currentProgress ?? ProgressDataModel(userId: userId));
      });
      _ref.invalidate(userProgressDataProvider(userId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      debugPrint('Error updating progress for user $userId: $e');
    }
  }

  // ✅ FIXED: Corrected streak calculation logic
  ProgressDataModel _updateStreak(
      ProgressDataModel progress, String activityType) {
    final now = DateTime.now();
    // Normalize 'now' to midnight to prevent issues with time zones and DST
    final today = DateTime(now.year, now.month, now.day);

    DateTime? lastDate;
    int currentStreak = 0;

    switch (activityType) {
      case 'meditation':
        lastDate = progress.lastMeditationDate;
        currentStreak = progress.meditationStreak;
        break;
      case 'journal':
        lastDate = progress.lastJournalDate;
        currentStreak = progress.journalStreak;
        break;
      case 'reading':
        lastDate = progress.lastReadingDate;
        currentStreak = progress.readingStreak;
        break;
      case 'music':
        lastDate = progress.lastMusicDate;
        currentStreak = progress.musicStreak;
        break;
    }

    if (lastDate != null) {
      // Normalize lastDate to midnight for accurate day comparison
      final lastPracticeDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastPracticeDay).inDays;

      if (difference == 0) {
        // Activity on the same day, streak does not change.
      } else if (difference == 1) {
        // Activity on the consecutive day, increment streak.
        currentStreak++;
      } else {
        // Gap of more than one day, reset streak.
        currentStreak = 1;
      }
    } else {
      // No previous activity, start streak at 1.
      currentStreak = 1;
    }


    switch (activityType) {
      case 'meditation':
        return progress.copyWith(
            meditationStreak: currentStreak, lastMeditationDate: now);
      case 'journal':
        return progress.copyWith(
            journalStreak: currentStreak, lastJournalDate: now);
      case 'reading':
        return progress.copyWith(
            readingStreak: currentStreak, lastReadingDate: now);
      case 'music':
        return progress.copyWith(
            musicStreak: currentStreak, lastMusicDate: now);
    }

    return progress;
  }


  Future<void> logJournalEntry(
      String userId, {
        required bool isNewEntry,
        required int moodRating,
        required DateTime timestamp,
      }) async {
    final dayKey =
        "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";

    final updater = (ProgressDataModel progress) {
      final newMoodRatings = Map<String, int>.from(progress.moodRatingsByDay);
      newMoodRatings[dayKey] = moodRating;

      final newJournalCount = isNewEntry
          ? progress.totalJournalEntries + 1
          : progress.totalJournalEntries;

      final updatedProgress = progress.copyWith(
        moodRatingsByDay: newMoodRatings,
        totalJournalEntries: newJournalCount,
      );

      return isNewEntry
          ? _updateStreak(updatedProgress, 'journal')
          : updatedProgress;
    };

    userId == 'guest'
        ? await _updateGuestProgress(updater)
        : await _updateFirestoreProgress(userId, updater);
  }

  Future<void> logBreathingSession(String userId, int durationMinutes) async {
    final updater = (ProgressDataModel progress) {
      final updatedProgress = progress.copyWith(
        totalMeditationMinutes:
        progress.totalMeditationMinutes + durationMinutes,
      );
      return _updateStreak(updatedProgress, 'meditation');
    };

    userId == 'guest'
        ? await _updateGuestProgress(updater)
        : await _updateFirestoreProgress(userId, updater);
  }

  Future<void> logReadingTime(String userId, int durationSeconds) async {
    if (durationSeconds < 3) return;
    final updater = (ProgressDataModel progress) {
      final updatedProgress = progress.copyWith(
          totalReadingSeconds: progress.totalReadingSeconds + durationSeconds);
      return _updateStreak(updatedProgress, 'reading');
    };

    userId == 'guest'
        ? await _updateGuestProgress(updater)
        : await _updateFirestoreProgress(userId, updater);
  }

  Future<void> logMusicTime(String userId, int durationSeconds) async {
    if (durationSeconds < 10) return;
    final updater = (ProgressDataModel progress) {
      final updatedProgress = progress.copyWith(
          totalMusicSeconds: progress.totalMusicSeconds + durationSeconds);
      return _updateStreak(updatedProgress, 'music');
    };

    userId == 'guest'
        ? await _updateGuestProgress(updater)
        : await _updateFirestoreProgress(userId, updater);
  }

  Future<void> logChatbotMessage(String userId) async {
    final updater = (ProgressDataModel progress) {
      return progress.copyWith(
          totalChatbotMessages: progress.totalChatbotMessages + 1);
    };
    userId == 'guest'
        ? await _updateGuestProgress(updater)
        : await _updateFirestoreProgress(userId, updater);
  }

  Future<void> logYogaTime(String userId, int durationMinutes) async {
    if (durationMinutes < 1) return;
    final updater = (ProgressDataModel progress) {
      return progress.copyWith(
          totalYogaMinutes: progress.totalYogaMinutes + durationMinutes);
    };
    userId == 'guest'
        ? await _updateGuestProgress(updater)
        : await _updateFirestoreProgress(userId, updater);
  }

  Future<void> logLaughingTherapyTime(
      String userId, int durationMinutes) async {
    if (durationMinutes < 1) return;
    final updater = (ProgressDataModel progress) {
      return progress.copyWith(
          totalLaughingTherapyMinutes:
          progress.totalLaughingTherapyMinutes + durationMinutes);
    };
    userId == 'guest'
        ? await _updateGuestProgress(updater)
        : await _updateFirestoreProgress(userId, updater);
  }
}

final progressNotifierProvider =
StateNotifierProvider<ProgressNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ProgressNotifier(firestoreService, storageService, ref);
});