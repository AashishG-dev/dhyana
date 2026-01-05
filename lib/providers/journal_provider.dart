// lib/providers/journal_provider.dart
import 'package:dhyana/core/services/storage_service.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/models/journal_entry_model.dart';
import 'package:dhyana/providers/auth_provider.dart';

const String _guestJournalKey = 'guest_journal_entries';

final guestJournalEntriesProvider =
StateProvider<List<JournalEntryModel>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final jsonList = storageService.getJsonList(_guestJournalKey);
  if (jsonList != null) {
    return jsonList
        .map((json) => JournalEntryModel.fromJson(json, json['id']))
        .toList();
  }
  return [];
});

final userJournalEntriesProvider =
StreamProvider.family<List<JournalEntryModel>, String>((ref, userId) {
  if (userId == 'guest') {
    return Stream.value(ref.watch(guestJournalEntriesProvider));
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  debugPrint('Fetching journal entries for user: $userId');
  return firestoreService.getJournalEntries(userId);
});

class JournalNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final Ref _ref;

  JournalNotifier(this._firestoreService, this._storageService, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> addJournalEntry(String userId, JournalEntryModel entry) async {
    state = const AsyncValue.loading();
    try {
      if (userId == 'guest') {
        final currentEntries = _ref.read(guestJournalEntriesProvider);
        final newEntry =
        entry.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
        final updatedEntries = [...currentEntries, newEntry];
        await _storageService.saveJsonList(
            _guestJournalKey, updatedEntries.map((e) => e.toJson()).toList());
        _ref.read(guestJournalEntriesProvider.notifier).state = updatedEntries;
      } else {
        await _firestoreService.addJournalEntry(userId, entry);
        // ✅ FIXED: Invalidate the provider to force a UI refresh from the local cache.
        _ref.invalidate(userJournalEntriesProvider(userId));
      }

      await _ref.read(progressNotifierProvider.notifier).logJournalEntry(
        userId,
        isNewEntry: true,
        moodRating: entry.moodRating,
        timestamp: entry.timestamp,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateJournalEntry(String userId, JournalEntryModel entry) async {
    state = const AsyncValue.loading();
    try {
      if (userId == 'guest') {
        final currentEntries = _ref.read(guestJournalEntriesProvider);
        final entryIndex = currentEntries.indexWhere((e) => e.id == entry.id);
        if (entryIndex != -1) {
          currentEntries[entryIndex] = entry;
          await _storageService.saveJsonList(
              _guestJournalKey, currentEntries.map((e) => e.toJson()).toList());
          _ref.read(guestJournalEntriesProvider.notifier).state = [
            ...currentEntries
          ];
        }
      } else {
        await _firestoreService.updateJournalEntry(userId, entry);
        // ✅ FIXED: Invalidate the provider to force a UI refresh from the local cache.
        _ref.invalidate(userJournalEntriesProvider(userId));
      }

      await _ref.read(progressNotifierProvider.notifier).logJournalEntry(
        userId,
        isNewEntry: false,
        moodRating: entry.moodRating,
        timestamp: entry.timestamp,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteJournalEntry(String userId, String entryId) async {
    state = const AsyncValue.loading();
    try {
      if (userId == 'guest') {
        final currentEntries = _ref.read(guestJournalEntriesProvider);
        currentEntries.removeWhere((e) => e.id == entryId);
        await _storageService.saveJsonList(
            _guestJournalKey, currentEntries.map((e) => e.toJson()).toList());
        _ref.read(guestJournalEntriesProvider.notifier).state = [
          ...currentEntries
        ];
      } else {
        await _firestoreService.deleteJournalEntry(userId, entryId);
        // ✅ FIXED: Invalidate the provider to force a UI refresh from the local cache.
        _ref.invalidate(userJournalEntriesProvider(userId));
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePinStatus(String userId, JournalEntryModel entry) async {
    final currentEntries = _ref.read(userJournalEntriesProvider(userId)).value ?? [];
    final pinnedCount = currentEntries.where((e) => e.isPinned).length;

    if (!entry.isPinned && pinnedCount >= 3) {
      throw Exception('You can only pin a maximum of 3 journal entries.');
    }

    final updatedEntry = entry.copyWith(isPinned: !entry.isPinned);
    // The updateJournalEntry function already handles invalidation, so we just call it.
    await updateJournalEntry(userId, updatedEntry);
  }
}

final journalNotifierProvider =
StateNotifierProvider<JournalNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return JournalNotifier(firestoreService, storageService, ref);
});