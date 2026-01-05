import 'package:dhyana/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dhyana/core/services/auth_service.dart';
import 'package:dhyana/core/services/firestore_service.dart';
import 'package:dhyana/core/services/api_service.dart';
import 'package:dhyana/core/services/cloudinary_service.dart';
import 'package:dhyana/core/services/notification_service.dart';
import 'package:dhyana/models/user_model.dart';

// --- Core Service Providers ---
final authServiceProvider = Provider<AuthService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(firestoreService, storageService);
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// --- Authentication State ---
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ✅ Handles full user session state
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  await for (final user in authService.authStateChanges) {
    if (user == null) {
      yield null;
    } else {
      final profile = await firestoreService.getUserProfile(user.uid);
      if (profile == null) {
        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: '',
        );
        await firestoreService.createUserProfileIfNotExists(newUser);
      }
      yield* firestoreService.getUserProfileStream(user.uid);

      // ✅ Schedule notifications when user logs in
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.requestPermissions();

      // 🔄 For quick testing: 1m, 2m, 3m delays
      await _scheduleTestLoginReminders(notificationService);
    }
  }
});

// --- PRIVATE HELPER for reminders ---
Future<void> _scheduleTestLoginReminders(
    NotificationService notificationService) async {
  try {
    debugPrint("🔄 Scheduling login reminders...");

    await notificationService.cancelNotification(201);
    await notificationService.cancelNotification(202);
    await notificationService.cancelNotification(203);

    final now = DateTime.now();

    await notificationService.scheduleOneTimeNotification(
      id: 201,
      title: 'Test Reminder 1',
      body: 'This fires after 1 minute',
      scheduledTime: now.add(const Duration(minutes: 1)),
      payload: '/meditation',
    );

    await notificationService.scheduleOneTimeNotification(
      id: 202,
      title: 'Test Reminder 2',
      body: 'This fires after 2 minutes',
      scheduledTime: now.add(const Duration(minutes: 2)),
      payload: '/progress',
    );

    await notificationService.scheduleOneTimeNotification(
      id: 203,
      title: 'Test Reminder 3',
      body: 'This fires after 3 minutes',
      scheduledTime: now.add(const Duration(minutes: 3)),
      payload: '/journal',
    );
  } catch (e) {
    debugPrint("❌ Failed to schedule reminders: $e");
  }
}
