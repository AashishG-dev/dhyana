// lib/core/services/chatbot_service.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:dhyana/core/services/api_service.dart'; // For making API calls
import 'package:dhyana/models/chat_message_model.dart'; // For ChatMessageModel
import 'package:dhyana/core/constants/app_constants.dart'; // For Gemini API key

/// Manages interaction with the AI-powered chatbot, specifically
/// integrating with the Gemini API. This service handles sending
/// messages to the chatbot and processing its responses.
class ChatbotService {
  final ApiService _apiService;

  ChatbotService(this._apiService);

  // The Gemini model to use. 'gemini-pro' is a common choice for text generation.
  static const String _geminiModel = 'gemini-2.0-flash';

  /// Sends a message to the Gemini chatbot and retrieves its response.
  ///
  /// [message]: The user's message to send to the chatbot.
  /// [chatHistory]: A list of previous chat messages to provide context to the AI.
  ///
  /// Returns the chatbot's response as a [ChatMessageModel].
  /// Throws an [Exception] if the API call fails.
  Future<ChatMessageModel> sendMessageToChatbot(
      String message, List<ChatMessageModel> chatHistory) async {
    try {
      // Construct the chat history in the format expected by the Gemini API.
      // The Gemini API expects a list of 'contents', where each content
      // has a 'role' (user/model) and 'parts' (text).
      final List<Map<String, dynamic>> contents = chatHistory.map((msg) {
        return {
          'role': msg.sender == MessageSender.user ? 'user' : 'model',
          'parts': [
            {'text': msg.text}
          ],
        };
      }).toList();

      // Add the current user's message to the contents.
      contents.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ],
      });

      // Construct the payload for the Gemini API request.
      final Map<String, dynamic> payload = {
        'contents': contents,
        // Optional: Add generationConfig for controlling response generation
        // 'generationConfig': {
        //   'temperature': 0.7, // Controls randomness of response
        //   'topP': 0.95,       // Controls diversity of response
        //   'topK': 40,         // Controls diversity of response
        // },
      };

      // Construct the API URL, including the API key.
      // The API key is appended as a query parameter.
      final String apiUrlPath =
          'v1beta/models/$_geminiModel:generateContent?key=${AppConstants.geminiApiKey}';

      debugPrint('Sending message to Gemini API: $message');

      // Make the POST request to the Gemini API.
      final Map<String, dynamic> response =
      await _apiService.post(apiUrlPath, payload, baseUrl: AppConstants.geminiApiBaseUrl);

      // Parse the response from the Gemini API.
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
          debugPrint('Received response from Gemini API: $chatbotResponseText');
          return ChatMessageModel(
            text: chatbotResponseText,
            sender: MessageSender.chatbot,
            timestamp: DateTime.now(),
          );
        }
      }
      // If the response structure is unexpected, throw an error.
      throw Exception('Invalid response format from Gemini API.');
    } catch (e) {
      debugPrint('Error sending message to chatbot: $e');
      rethrow; // Re-throw the exception for higher-level error handling
    }
  }

  /// Provides static crisis support resources.
  /// This is a placeholder and could be expanded to fetch dynamic resources
  /// from Firestore or another API.
  List<String> getCrisisSupportResources() {
    return [
      'If you are in crisis, please reach out to a professional immediately.',
      'National Suicide Prevention Lifeline: 988',
      'Crisis Text Line: Text HOME to 741741',
      'Emergency Services: Your local emergency number (e.g., 911 in the US)',
      'Remember, you are not alone and help is available.',
    ];
  }
}
