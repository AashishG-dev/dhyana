// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  // Singleton pattern to ensure only one instance of the service
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();
    // Set the local location (e.g., for India)
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Android Initialization Settings
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    // fallback to launcher icon

    // iOS/macOS Initialization Settings
    const DarwinInitializationSettings darwinInitializationSettings =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Request notification permissions for Android 13+ and iOS.
  Future<void> requestPermissions() async {
    // Android 13+ permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Shows an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'dhyana_immediate_channel',
      'Immediate Notifications',
      channelDescription: 'Channel for important immediate notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, notificationDetails);
  }

  /// ✅ NEW METHOD: Schedules a one-time notification at a specific DateTime
  Future<void> scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final location = tz.local;
    final scheduledDate = tz.TZDateTime.from(scheduledTime, location);

    const androidDetails = AndroidNotificationDetails(
      'dhyana_scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled one-time notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint("⏰ One-time notification scheduled: $title for $scheduledDate");
  }

  /// Schedules a daily notification at a specific time.
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time has already passed today, schedule it for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'dhyana_daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Channel for daily learning reminders.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time, // repeat daily at same time
      payload: payload,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint("📅 Daily notification scheduled for: $scheduledDate with payload: $payload");
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint("🗑️ All notifications cancelled");
  }

  /// Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint("🗑️ Cancelled notification with ID: $id");
  }

  /// Get all pending notifications (useful for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Theme.of(NavigatorKey.currentContext!).platform == TargetPlatform.android) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS doesn't have a direct way to check this
  }
}

// Helper class for getting context (you might need to adjust this based on your app structure)
class NavigatorKey {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext? get currentContext => navigatorKey.currentContext;
}