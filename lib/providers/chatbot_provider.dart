// lib/core/providers/chatbot_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'package:dhyana/core/services/chatbot_service.dart'; // Import ChatbotService
import 'package:dhyana/models/chat_message_model.dart'; // Import ChatMessageModel
import 'package:dhyana/providers/auth_provider.dart'; // Import apiServiceProvider

/// Provides an instance of [ChatbotService].
/// It depends on [apiServiceProvider] for making Gemini API calls.
final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatbotService(apiService);
});

/// Manages the state of the chatbot conversation (list of messages).
final chatMessagesProvider =
StateNotifierProvider<ChatMessagesNotifier, List<ChatMessageModel>>((ref) {
  return ChatMessagesNotifier();
});

/// A [StateNotifier] to manage the list of chat messages.
class ChatMessagesNotifier extends StateNotifier<List<ChatMessageModel>> {
  ChatMessagesNotifier() : super([]);

  /// Adds a new message to the conversation.
  void addMessage(ChatMessageModel message) {
    state = [...state, message];
  }

  /// Clears the entire chat history.
  void clearChat() {
    state = [];
  }
}
