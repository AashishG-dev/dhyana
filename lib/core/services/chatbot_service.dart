// lib/core/services/chatbot_service.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:dhyana/core/services/api_service.dart'; // For making API calls
import 'package:dhyana/models/chat_message_model.dart'; // For ChatMessageModel
import 'package:dhyana/core/constants/app_constants.dart'; // For Gemini API key

class ChatbotService {
  final ApiService _apiService;

  ChatbotService(this._apiService);

  static const String _geminiModel = 'gemini-2.5-flash';

  // System prompt to define the chatbot's personality and role
  static const String _systemPrompt = '''
You are Dhyana, a compassionate and empathetic AI wellness companion specializing in stress relief and mental health support. Your primary role is to help users manage stress, anxiety, and emotional challenges. You can also answer general questions and provide information. If asked to generate code, you must format it within proper markdown code blocks.

**Core Principles:**
- Always respond with empathy, warmth, and understanding
- Provide practical stress relief techniques and coping strategies
- Encourage mindfulness, meditation, and self-care practices
- Offer emotional validation and support without judgment
- Suggest healthy lifestyle changes and wellness tips
- Know when to recommend professional help for serious issues

**Communication Style:**
- Use a gentle, caring, and non-judgmental tone
- Use markdown for formatting (bolding, lists, etc.) to improve readability.
- Keep responses concise but meaningful (2-4 sentences typically)
- Include relevant emojis to convey warmth (🌸, 💚, 🧘‍♀️, ✨, 🌿)
- Ask follow-up questions to better understand the user's needs

**Important Guidelines:**
- **You must always respond in English**, unless the user explicitly asks you to use a different language.
- Never provide medical diagnosis or replace professional therapy
- Always encourage seeking professional help for serious mental health concerns
- If a user mentions self-harm or crisis, immediately provide crisis resources.
''';

  Future<ChatMessageModel> sendMessageToChatbot(
      String message, List<ChatMessageModel> chatHistory) async {
    try {
      final List<Map<String, dynamic>> contents = [];

      if (chatHistory.isEmpty ||
          !chatHistory.any((msg) => msg.sender == MessageSender.chatbot &&
              msg.text.contains('Dhyana'))) {
        contents.add(<String, dynamic>{
          'role': 'user',
          'parts': <Map<String, dynamic>>[
            <String, dynamic>{'text': _systemPrompt}
          ],
        });
        contents.add(<String, dynamic>{
          'role': 'model',
          'parts': <Map<String, dynamic>>[
            <String, dynamic>{'text': 'I understand. I am Dhyana, your compassionate AI wellness companion, ready to support you with stress relief and emotional wellbeing. How are you feeling today? 🌸'}
          ],
        });
      }

      for (final msg in chatHistory) {
        if (msg.sender == MessageSender.chatbot &&
            msg.text.contains('👋 Hello! I\'m Dhyana')) {
          continue;
        }

        contents.add(<String, dynamic>{
          'role': msg.sender == MessageSender.user ? 'user' : 'model',
          'parts': <Map<String, dynamic>>[
            <String, dynamic>{'text': msg.text}
          ],
        });
      }

      contents.add(<String, dynamic>{
        'role': 'user',
        'parts': <Map<String, dynamic>>[
          <String, dynamic>{'text': message}
        ],
      });

      final Map<String, dynamic> payload = <String, dynamic>{
        'contents': contents,
        'generationConfig': <String, dynamic>{
          'temperature': 0.8,
          'topP': 0.95,
          'topK': 40,
          'maxOutputTokens': 2048,
        },
        'safetySettings': [
          {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'}
        ],
      };

      final String apiUrlPath = 'v1beta/models/$_geminiModel:generateContent';

      debugPrint('Sending message to Dhyana AI: $message');

      final Map<String, dynamic> response = await _apiService.post(
        apiUrlPath,
        payload,
        baseUrl: AppConstants.geminiApiBaseUrl,
        headers: <String, String>{
          'x-goog-api-key': AppConstants.geminiApiKey,
        },
      );

      if (response.containsKey('candidates') &&
          response['candidates'] is List &&
          response['candidates'].isNotEmpty) {
        final candidate = response['candidates'][0];
        if (candidate.containsKey('content') &&
            candidate['content'] is Map &&
            candidate['content'].containsKey('parts') &&
            candidate['content']['parts'] is List &&
            candidate['content']['parts'].isNotEmpty) {
          final String chatbotResponseText = candidate['content']['parts'][0]['text'];
          debugPrint('Received response from Dhyana AI: $chatbotResponseText');
          return ChatMessageModel(
            text: chatbotResponseText,
            sender: MessageSender.chatbot,
            timestamp: DateTime.now(),
          );
        }
      }

      throw Exception('Invalid response format from Gemini API.');
    } catch (e) {
      debugPrint('Error sending message to chatbot: $e');
      rethrow;
    }
  }

  List<String> getCrisisSupportResources() {
    return [
      '🚨 **IMMEDIATE CRISIS SUPPORT (India)** 🚨',
      'If you are in immediate danger, please dial **112** for emergency services.',
      '**24/7 Mental Health Helplines in India:**',
      '• **KIRAN Mental Health Helpline (Govt. of India):** 1800-599-0019',
      '• **Vandrevala Foundation Helpline:** 1860-266-2345 or 9999-666-555',
      '• **AASRA (Suicide Prevention & Counselling):** +91-98204 66726',
      '• **Snehi Helpline:** +91-95822 16811',
      '**Remember:**',
      '• You are not alone in this struggle 💚',
      '• These feelings are temporary, even when they don\'t feel like it. 🌸',
      '• Professional help is available and effective 🧘‍♀️',
      '• Your life has value and meaning ✨',
      'Please reach out to a mental health professional, trusted friend, or family member. You deserve support and care. 🌿'
    ];
  }

}