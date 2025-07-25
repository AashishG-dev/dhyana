// lib/core/services/notification_service.dart
import 'dart:io';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern to ensure only one instance of this service exists.
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initializes the notification plugin. Call this once in main.dart.
  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      // Request default permissions on iOS/macOS.
      // The user will be prompted on the first notification schedule/show if not already granted.
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );
    debugPrint('NotificationService initialized.');
  }

  /// Requests permissions for Android and iOS.
  /// Returns true if permissions are granted.
  Future<bool> requestPermissions() async {
    bool? result = false;
    if (Platform.isIOS || Platform.isMacOS) {
      result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      result = await androidImplementation?.requestNotificationsPermission();
    }
    return result ?? false;
  }

  /// Schedules a daily meditation reminder.
  Future<void> scheduleMeditationReminder(
      DateTime time, String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      AppConstants.meditationReminderChannelId,
      AppConstants.meditationReminderChannelName,
      channelDescription: AppConstants.meditationReminderChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Unique ID for this notification type
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'meditation_reminder',
    );
    debugPrint('Meditation reminder scheduled for: $scheduledDate');
  }

  /// Shows an immediate notification.
  Future<void> showMindfulMoment(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      AppConstants.mindfulMomentChannelId,
      AppConstants.mindfulMomentChannelName,
      channelDescription: AppConstants.mindfulMomentChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(
      1, // Unique ID for this type of notification
      title,
      body,
      platformDetails,
      payload: 'mindful_moment',
    );
  }

  /// Cancels a specific notification by its ID.
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Notification with ID $id cancelled.');
  }

  /// Retrieves a list of all pending scheduled notifications.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Checks if notification permissions have been granted.
  Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return granted ?? false;
    } else if (Platform.isIOS) {
      // For iOS, the recommended approach is to simply request permissions.
      // The OS handles showing the prompt only once. Subsequent calls return the existing status.
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Calculates the next instance of a given time for scheduling.
  tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
