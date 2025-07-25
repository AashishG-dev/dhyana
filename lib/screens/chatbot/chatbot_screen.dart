// lib/screens/chatbot/chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/chatbot_provider.dart'; // For chatbotService and chatMessagesProvider
import 'package:dhyana/providers/auth_provider.dart'; // For currentUserProfileProvider
import 'package:dhyana/models/chat_message_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/loading_widget.dart'; // For loading indicator

/// A screen for interacting with the AI chatbot.
/// It displays the conversation history and allows users to send new messages.
/// Integrates with `ChatbotService` and `chatMessagesProvider` for state management.
class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false; // To manage loading state for sending messages

  @override
  void initState() {
    super.initState();
    // Optionally, add an initial welcome message from the chatbot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messages = ref.read(chatMessagesProvider);
      if (messages.isEmpty) {
        ref.read(chatMessagesProvider.notifier).addMessage(
          ChatMessageModel(
            text: 'Hello! I am Dhyana\'s AI companion. How can I assist you on your mindful journey today?',
            sender: MessageSender.chatbot,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls to the bottom of the chat list.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Handles sending a new message to the chatbot.
  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Add user message to the chat history
    final userMessage = ChatMessageModel(
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    ref.read(chatMessagesProvider.notifier).addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    try {
      final chatbotService = ref.read(chatbotServiceProvider);
      final currentChatHistory = ref.read(chatMessagesProvider);

      // Send message to chatbot service
      final chatbotResponse = await chatbotService.sendMessageToChatbot(
        text,
        currentChatHistory, // Pass entire history for context
      );

      // Add chatbot's response to the chat history
      ref.read(chatMessagesProvider.notifier).addMessage(chatbotResponse);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message to chatbot: $e');
      // Add an error message from the chatbot
      ref.read(chatMessagesProvider.notifier).addMessage(
        ChatMessageModel(
          text: 'I apologize, but I encountered an error. Please try again later.',
          sender: MessageSender.chatbot,
          timestamp: DateTime.now(),
        ),
      );
      _scrollToBottom();
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// Displays crisis support resources in the chat.
  void _showCrisisResources() {
    final chatbotService = ref.read(chatbotServiceProvider);
    final resources = chatbotService.getCrisisSupportResources();
    for (String resource in resources) {
      ref.read(chatMessagesProvider.notifier).addMessage(
        ChatMessageModel(
          text: resource,
          sender: MessageSender.chatbot,
          timestamp: DateTime.now(),
        ),
      );
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final chatMessages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dhyana AI Chatbot',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.crisis_alert_outlined,
              color: isDarkMode ? AppColors.textDark : AppColors.textLight,
            ),
            tooltip: 'Crisis Support',
            onPressed: _showCrisisResources,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_outlined,
              color: isDarkMode ? AppColors.textDark : AppColors.textLight,
            ),
            tooltip: 'Clear Chat',
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clearChat();
              // Add initial welcome message again after clearing
              ref.read(chatMessagesProvider.notifier).addMessage(
                ChatMessageModel(
                  text: 'Hello! I am Dhyana\'s AI companion. How can I assist you on your mindful journey today?',
                  sender: MessageSender.chatbot,
                  timestamp: DateTime.now(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF212121)]
                : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  final bool isUser = message.sender == MessageSender.user;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall / 2),
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      decoration: BoxDecoration(
                        color: isUser
                            ? (isDarkMode ? AppColors.primaryLightGreen.withOpacity(0.2) : AppColors.primaryLightBlue.withOpacity(0.2))
                            : (isDarkMode ? AppColors.glassDarkSurface : AppColors.glassLightSurface),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                          topRight: Radius.circular(AppConstants.borderRadiusMedium),
                          bottomLeft: isUser ? Radius.circular(AppConstants.borderRadiusMedium) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : Radius.circular(AppConstants.borderRadiusMedium),
                        ),
                        border: Border.all(
                          color: isUser
                              ? (isDarkMode ? AppColors.primaryLightGreen.withOpacity(0.5) : AppColors.primaryLightBlue.withOpacity(0.5))
                              : (isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isUser
                                  ? (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue)
                                  : (isDarkMode ? AppColors.textDark : AppColors.textLight),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.all(AppConstants.paddingSmall),
                child: LoadingWidget(message: 'AI is typing...'),
              ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: CustomTextField(
                controller: _messageController,
                hintText: 'Type your message...',
                onSubmitted: (value) => _sendMessage(),
                suffixIcon: Icon(
                  Icons.send,
                  color: isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                ),
                onSuffixIconPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
