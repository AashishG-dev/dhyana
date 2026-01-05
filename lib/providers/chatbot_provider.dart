// lib/core/providers/chatbot_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/core/services/chatbot_service.dart';
import 'package:dhyana/models/chat_message_model.dart';
import 'package:dhyana/providers/auth_provider.dart';

/// Provides an instance of [ChatbotService].
final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatbotService(apiService);
});

/// Manages the state of the chatbot conversation.
final chatMessagesProvider =
StateNotifierProvider<ChatMessagesNotifier, List<ChatMessageModel>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessageModel>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessageModel message) {
    state = [...state, message];
  }

  void clearChat() {
    state = [];
  }
}
