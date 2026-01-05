// lib/screens/chatbot/chatbot_screen.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:dhyana/widgets/common/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/chatbot_provider.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/models/chat_message_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:go_router/go_router.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  // State to track which messages have been copied
  final Set<String> _copiedMessages = <String>{};
  // State to track which code blocks have been copied
  final Set<String> _copiedCodeBlocks = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messages = ref.read(chatMessagesProvider);
      if (messages.isEmpty) {
        ref.read(chatMessagesProvider.notifier).addMessage(
          ChatMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text:
            'Hello! I am Dhyana, your mindful AI companion. How are you feeling today?',
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleCopy(String textToCopy, String messageId) {
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      _copiedMessages.add(messageId);
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedMessages.remove(messageId);
        });
      }
    });
  }

  void _handleCodeCopy(String code, String codeId) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      _copiedCodeBlocks.add(codeId);
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedCodeBlocks.remove(codeId);
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    ref.read(chatMessagesProvider.notifier).addMessage(userMessage);

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null) {
      ref.read(progressNotifierProvider.notifier).logChatbotMessage(userId);
      ref.read(taskCompletionServiceProvider).completeTask('talk_to_dhyana');
    }

    _messageController.clear();
    _scrollToBottom();

    try {
      final chatbotService = ref.read(chatbotServiceProvider);
      final history = ref.read(chatMessagesProvider);

      final response =
      await chatbotService.sendMessageToChatbot(text, history);

      ref.read(chatMessagesProvider.notifier).addMessage(response.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
      _scrollToBottom();
    } catch (e) {
      ref.read(chatMessagesProvider.notifier).addMessage(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
          'Oops, something went wrong. Please try again in a moment.',
          sender: MessageSender.chatbot,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showCrisisResources() {
    final chatbotService = ref.read(chatbotServiceProvider);
    final resources = chatbotService.getCrisisSupportResources();
    for (final r in resources) {
      ref.read(chatMessagesProvider.notifier).addMessage(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: r,
          sender: MessageSender.chatbot,
          timestamp: DateTime.now(),
        ),
      );
    }
    _scrollToBottom();
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.sender == MessageSender.user;
    final bool wasCopied = _copiedMessages.contains(message.id);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? (isDarkMode
              ? AppColors.primaryLightGreen
              : AppColors.primaryLightBlue)
              : (isDarkMode
              ? const Color(0xFF2E3D4F)
              : const Color(0xFFF0F4F8)),
          borderRadius:
          BorderRadius.circular(AppConstants.borderRadiusLarge).subtract(
            isUser
                ? const BorderRadius.only(bottomRight: Radius.circular(4))
                : const BorderRadius.only(bottomLeft: Radius.circular(4)),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MarkdownBody(
              data: message.text,
              shrinkWrap: true,
              fitContent: true,
              styleSheet:
              MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: AppTextStyles.bodyMedium.copyWith(
                  color: isDarkMode || isUser ? Colors.white : Colors.black87,
                ),
                code: AppTextStyles.bodyMedium.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor: isDarkMode || isUser
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  color: isDarkMode || isUser ? Colors.white : Colors.black87,
                ),
                codeblockDecoration: const BoxDecoration(
                  color: Color(0xFF1E2A3A),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                blockSpacing: 8.0,
              ),
              builders: <String, MarkdownElementBuilder>{
                'code': CodeBlockBuilder(
                  messageId: message.id ?? '',
                  onCopy: _handleCodeCopy,
                  copiedCodeBlocks: _copiedCodeBlocks,
                ),
              },
            ),
            if (!isUser) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _handleCopy(message.text, message.id ?? ''),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          wasCopied ? Icons.check : Icons.copy_all_outlined,
                          size: 16,
                          color: wasCopied
                              ? (isDarkMode
                              ? AppColors.primaryLightGreen
                              : AppColors.primaryLightBlue)
                              : (isDarkMode
                              ? Colors.white70
                              : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chatMessages = ref.watch(chatMessagesProvider);
    final musicPlayerState = ref.watch(musicPlayerProvider);
    final shouldShowMiniPlayer = musicPlayerState.currentTrack != null &&
        (musicPlayerState.playerState == PlayerState.playing ||
            musicPlayerState.playerState == PlayerState.paused);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Dhyana AI',
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.crisis_alert_outlined),
              tooltip: 'Crisis Support',
              onPressed: _showCrisisResources,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Clear Chat',
              onPressed: () {
                ref.read(chatMessagesProvider.notifier).clearChat();
                ref.read(chatMessagesProvider.notifier).addMessage(
                  ChatMessageModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text:
                    'Hi again! How can I help you find calm today?',
                    sender: MessageSender.chatbot,
                    timestamp: DateTime.now(),
                  ),
                );
              },
            ),
            const ProfileAvatar(),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [AppColors.backgroundDark, const Color(0xFF1C1C1C)]
                  : [AppColors.backgroundLight, const Color(0xFFF7F7F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: chatMessages.length,
                  itemBuilder: (_, int i) =>
                      _buildMessageBubble(chatMessages[i]),
                ),
              ),
              if (_isSending)
                const Padding(
                  padding: EdgeInsets.all(AppConstants.paddingSmall),
                  child: LoadingWidget(message: 'Dhyana is typing...'),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.glassDarkSurface.withOpacity(0.6)
                      : const Color.fromRGBO(255, 255, 255, 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.borderRadiusLarge),
                    topRight: Radius.circular(AppConstants.borderRadiusLarge),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDarkMode
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: isDarkMode
                                ? AppColors.textDark.withOpacity(0.6)
                                : AppColors.textLight.withOpacity(0.6),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: isDarkMode
                            ? AppColors.primaryLightGreen
                            : AppColors.primaryLightBlue,
                      ),
                      onPressed: _sendMessage,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowMiniPlayer) const MiniMusicPlayer(),
            const CustomBottomNavBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final String messageId;
  final Function(String text, String codeId) onCopy;
  final Set<String> copiedCodeBlocks;

  CodeBlockBuilder({
    required this.messageId,
    required this.onCopy,
    required this.copiedCodeBlocks,
  });

  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    if (element.tag != 'code' && element.tag != 'pre') {
      return null;
    }

    if (element.tag == 'code') {
      final textContent = element.textContent ?? '';
      if (!textContent.contains('\n') && textContent.length < 100) {
        return null;
      }
    }

    String codeContent = element.textContent ?? '';

    if (codeContent.trim().isEmpty) {
      return null;
    }

    final codeId = '${messageId}_${codeContent.hashCode}';
    final wasCopied = copiedCodeBlocks.contains(codeId);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: const BoxDecoration(
              color: Color(0xFF2A3A4D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Code',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => onCopy(codeContent, codeId),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: wasCopied
                          ? Colors.green.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(
                        color: wasCopied ? Colors.green : Colors.white30,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          wasCopied ? Icons.check : Icons.copy,
                          size: 14,
                          color: wasCopied ? Colors.green : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          wasCopied ? 'Copied!' : 'Copy',
                          style: TextStyle(
                            color: wasCopied ? Colors.green : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                codeContent,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}