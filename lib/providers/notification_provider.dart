// lib/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dhyana/core/services/notification_service.dart';

/// Provider that creates and exposes the single instance of NotificationService.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// The main provider for notification settings.
/// Widgets can watch this provider to react to changes in reminder status.
final notificationSettingsProvider =
StateNotifierProvider<NotificationSettingsNotifier, bool>((ref) {
  // Pass the ref to the notifier so it can read other providers.
  return NotificationSettingsNotifier(ref);
});

/// A [StateNotifier] to manage notification-related settings and actions.
class NotificationSettingsNotifier extends StateNotifier<bool> {
  final Ref _ref;
  // Store an instance of the service to call its methods.
  late final NotificationService _notificationService;

  // The constructor now accepts a Ref and initializes the service instance.
  NotificationSettingsNotifier(this._ref) : super(false) {
    // Read the service provider to get the service instance.
    _notificationService = _ref.read(notificationServiceProvider);
    _loadReminderStatus();
  }

  /// Loads the initial status of meditation reminders.
  Future<void> _loadReminderStatus() async {
    final pending = await _notificationService.getPendingNotifications();
    state = pending.any((notification) =>
    notification.id == 0 && notification.payload == 'meditation_reminder');
    debugPrint('Meditation reminders initial status: $state');
  }

  /// Toggles the meditation reminder on or off.
  Future<void> toggleMeditationReminder(bool enable, {TimeOfDay? time}) async {
    if (enable) {
      if (time == null) {
        debugPrint('Cannot enable reminder: time is null.');
        return;
      }
      final now = DateTime.now();
      final scheduledTime =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
      await _notificationService.scheduleMeditationReminder(
        scheduledTime,
        'Daily Meditation Reminder',
        'It\'s time for your daily dose of mindfulness!',
      );
      state = true;
      debugPrint(
          'Meditation reminder enabled at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}.');
    } else {
      await _notificationService.cancelNotification(0);
      state = false;
      debugPrint('Meditation reminder disabled.');
    }
  }

  /// Shows an immediate mindful moment notification.
  Future<void> triggerMindfulMoment() async {
    await _notificationService.showMindfulMoment(
      'Mindful Moment',
      'Take a deep breath and notice your surroundings.',
    );
    debugPrint('Mindful moment triggered.');
  }

  /// Requests notification permissions.
  Future<bool> requestNotificationPermissions() async {
    return await _notificationService.requestPermissions();
  }

  /// Checks if notification permissions are granted.
  Future<bool> areNotificationPermissionsGranted() async {
    return await _notificationService.arePermissionsGranted();
  }
}
