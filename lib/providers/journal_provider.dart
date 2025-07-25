// lib/core/providers/journal_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:dhyana/core/services/firestore_service.dart'; // Import FirestoreService
import 'package:dhyana/models/journal_entry_model.dart'; // Import JournalEntryModel
import 'package:dhyana/providers/auth_provider.dart'; // To access firestoreServiceProvider and authStateProvider

/// Provides a stream of [JournalEntryModel]s for the current user.
/// It depends on the `authStateProvider` to get the user's ID.
/// This is a family provider because it needs the `userId` to fetch specific journal entries.
final userJournalEntriesProvider =
StreamProvider.family<List<JournalEntryModel>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  debugPrint('Fetching journal entries for user: $userId');
  return firestoreService.getJournalEntries(userId);
});

/// A [StateNotifier] to manage the creation, update, and deletion of journal entries.
class JournalNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  JournalNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  /// Adds a new journal entry.
  Future<void> addJournalEntry(String userId, JournalEntryModel entry) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.addJournalEntry(userId, entry);
      state = const AsyncValue.data(null);
      debugPrint('Journal entry added successfully.');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      debugPrint('Error adding journal entry: $e');
    }
  }

  /// Updates an existing journal entry.
  Future<void> updateJournalEntry(String userId, JournalEntryModel entry) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateJournalEntry(userId, entry);
      state = const AsyncValue.data(null);
      debugPrint('Journal entry updated successfully.');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      debugPrint('Error updating journal entry: $e');
    }
  }

  /// Deletes a journal entry.
  Future<void> deleteJournalEntry(String userId, String entryId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteJournalEntry(userId, entryId);
      state = const AsyncValue.data(null);
      debugPrint('Journal entry deleted successfully.');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      debugPrint('Error deleting journal entry: $e');
    }
  }
}

/// The main provider for managing journal entries actions.
/// Widgets can use this to perform CRUD operations on journal entries.
final journalNotifierProvider =
StateNotifierProvider<JournalNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return JournalNotifier(firestoreService);
});
