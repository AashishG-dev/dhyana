// lib/providers/user_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/providers/auth_provider.dart';

// ✅ ADDED: A provider that streams the list of all users for the admin panel
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAllUsers();
});

/// StateNotifier for handling user profile updates.
class UserProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final Ref _ref;

  UserProfileNotifier(this._firestoreService, this._ref)
      : super(const AsyncValue.data(null));

  /// Updates the user's profile in Firestore.
  Future<void> updateUserProfile(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateUserProfile(user);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // ✅ ADDED: Method to update a specific user's role
  Future<void> updateUserRole(String userId, String newRole) async {
    state = const AsyncValue.loading();
    try {
      final userProfile = await _firestoreService.getUserProfile(userId);
      if (userProfile == null) throw Exception('User profile not found');

      final updatedUser = userProfile.copyWith(role: newRole);
      await _firestoreService.updateUserProfile(updatedUser);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // ✅ ADDED: Method to delete a user's Firestore data
  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteUserProfile(userId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Toggles a meditation's favorite status for a given user.
  Future<void> toggleFavoriteMeditation(
      String userId, String meditationId) async {
    state = const AsyncValue.loading();
    try {
      final userProfile = await _firestoreService.getUserProfile(userId);
      if (userProfile == null) throw Exception('User profile not found');

      final currentFavorites = userProfile.favoriteMeditationIds.toList();
      if (currentFavorites.contains(meditationId)) {
        currentFavorites.remove(meditationId);
      } else {
        currentFavorites.add(meditationId);
      }

      await _firestoreService.updateUserProfile(
        userProfile.copyWith(favoriteMeditationIds: currentFavorites),
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ✅ ADDED: Method to delete a user's data
  Future<void> deleteUserData(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteUserData(userId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider for the UserProfileNotifier.
final userProfileNotifierProvider =
StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return UserProfileNotifier(firestoreService, ref);
});