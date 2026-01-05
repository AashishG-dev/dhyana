// lib/core/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion (if storing in Firestore)

/// Defines the data structure for a notification within the Dhyana application.
/// This model can represent both scheduled local notifications and potentially
/// notifications fetched from a backend (if you expand to push notifications).
/// It includes properties like ID, title, body, payload, scheduled time, and read status.
class NotificationModel {
  final String? id; // Unique ID for the notification (e.g., from FlutterLocalNotificationsPlugin or Firestore)
  final String title;
  final String body;
  final String? payload; // Optional data to pass when notification is tapped
  final DateTime? scheduledTime; // The time at which the notification is scheduled (if applicable)
  final bool isRead; // To track if the user has seen/read the notification
  final String type; // e.g., 'meditation_reminder', 'mindful_moment', 'general_info'
  final DateTime createdAt; // When the notification record was created

  /// Constructor for NotificationModel.
  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    this.payload,
    this.scheduledTime,
    this.isRead = false, // Default to unread
    required this.type,
    required this.createdAt,
  });

  /// Factory constructor to create a [NotificationModel] from a JSON map.
  /// This can be used for deserializing from local storage or Firestore.
  /// [docId] is the Firestore document ID (optional).
  factory NotificationModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return NotificationModel(
      id: docId ?? json['id'] as String?, // Use docId if provided, else from JSON
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] as String?,
      // Convert Firestore Timestamp to DateTime, or parse ISO string if from local storage
      scheduledTime: (json['scheduledTime'] is Timestamp)
          ? (json['scheduledTime'] as Timestamp).toDate()
          : (json['scheduledTime'] != null ? DateTime.parse(json['scheduledTime'] as String) : null),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts this [NotificationModel] instance into a JSON map.
  /// This can be used for serializing to local storage or Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      // Store DateTime as ISO 8601 string for local storage, or Timestamp for Firestore
      'scheduledTime': scheduledTime?.toIso8601String(), // Or Timestamp.fromDate(scheduledTime!) for Firestore
      'isRead': isRead,
      'type': type,
      'createdAt': createdAt.toIso8601String(), // Or Timestamp.fromDate(createdAt) for Firestore
    };
  }

  /// Creates a copy of this NotificationModel with updated values.
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? payload,
    DateTime? scheduledTime,
    bool? isRead,
    String? type,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: "$title", type: $type, scheduledTime: $scheduledTime, isRead: $isRead)';
  }
}
