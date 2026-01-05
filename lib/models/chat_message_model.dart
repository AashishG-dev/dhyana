// lib/core/models/chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp conversion

/// Enum to define the sender of a chat message.
enum MessageSender {
  user,
  chatbot,
}

/// Defines the data structure for a single message in the chatbot conversation.
/// This model includes properties like sender, text content, and timestamp.
/// It also provides methods for serialization to and from JSON.
class ChatMessageModel {
  final String? id; // Optional document ID from Firestore if stored
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  /// Constructor for ChatMessageModel.
  ChatMessageModel({
    this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  /// Factory constructor to create a [ChatMessageModel] from a JSON map.
  /// This is used when retrieving chat messages from Firestore (if stored).
  /// [docId] is the Firestore document ID (optional).
  factory ChatMessageModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return ChatMessageModel(
      id: docId,
      text: json['text'] as String,
      sender: (json['sender'] as String) == 'user' ? MessageSender.user : MessageSender.chatbot,
      // Convert Firestore Timestamp to DateTime
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Converts this [ChatMessageModel] instance into a JSON map.
  /// This is used when saving chat messages to Firestore (if stored).
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender == MessageSender.user ? 'user' : 'chatbot',
      // Convert DateTime to Firestore Timestamp
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Creates a copy of this ChatMessageModel with updated values.
  ChatMessageModel copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, text: "$text", sender: $sender, timestamp: $timestamp)';
  }
}
