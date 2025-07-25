// lib/core/providers/user_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/providers/auth_provider.dart';

// ✅ FIX: This provider now uses a real-time stream from Firestore.
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        debugPrint('User authenticated, listening to profile stream for UID: ${user.uid}');
        return firestoreService.getUserProfileStream(user.uid);
      } else {
        debugPrint('No user logged in.');
        return Stream.value(null);
      }
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});


class UserProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final Ref _ref;

  UserProfileNotifier(this._firestoreService, this._ref) : super(const AsyncValue.data(null));

  Future<void> updateUserProfile(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      if (user.id == null) {
        throw Exception('User ID cannot be null for profile update.');
      }
      await _firestoreService.updateUserProfile(user);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ✅ FIX: This logic is now simpler and more robust.
  Future<void> toggleFavoriteMeditation(String userId, String meditationId) async {
    state = const AsyncValue.loading();
    try {
      // We no longer need to invalidate the provider; the stream will update automatically.
      final userProfile = await _firestoreService.getUserProfile(userId);
      if (userProfile == null) throw Exception('User profile not found');

      final currentFavorites = userProfile.favoriteMeditationIds.toList();
      if (currentFavorites.contains(meditationId)) {
        currentFavorites.remove(meditationId);
      } else {
        currentFavorites.add(meditationId);
      }

      await _firestoreService.updateUserProfile(
          userProfile.copyWith(favoriteMeditationIds: currentFavorites)
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return UserProfileNotifier(firestoreService, ref);
});