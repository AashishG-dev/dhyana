// lib/models/quote_model.dart
import 'dart:convert';

class QuoteModel {
  final String text;
  final String author;

  QuoteModel({required this.text, required this.author});

  // Factory to create a QuoteModel from the API's JSON response
  factory QuoteModel.fromJson(String str) {
    final jsonData = json.decode(str);
    // The API returns a list with one quote object
    final quoteData = jsonData[0];
    return QuoteModel(
      text: quoteData['q'] as String? ?? 'No quote text available.',
      author: quoteData['a'] as String? ?? 'Unknown',
    );
  }
}
