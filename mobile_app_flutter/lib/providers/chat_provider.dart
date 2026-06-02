import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.content, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final _api = ApiService();
  List<ChatMessage> _messages = [
    ChatMessage(content: 'Namaskara! ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಲ್ಲೆ?', isUser: false),
  ];
  List<String> _suggestions = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  List<String> get suggestions => _suggestions;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String question, {String language = 'en'}) async {
    // Add user message
    _messages.add(ChatMessage(content: question, isUser: true));
    _isLoading = true;
    _suggestions = [];
    notifyListeners();

    try {
      if (question == "ನನ್ನ ಟೊಮ್ಯಾಟೋ ಎಲೆಗಳಲ್ಲಿ ಹಳದಿ ಚುಕ್ಕೆಗಳಿವೆ.") {
        // UI Demo simulation based on Figma screen
        await Future.delayed(const Duration(seconds: 1));
        _messages.add(ChatMessage(content: 'ಇದು Early Blight ಆಗಿರಬಹುದು. Mancozeb 2g/L ಸಿಂಪಡಿಸಿ. Camera ಬಳಸಿ Scan ಮಾಡಿ?', isUser: false));
        _suggestions = ['ಹೌದು, ತೋರಿಸಿ 🌿'];
      } else {
        final data = await _api.sendChatMessage(question, language: language);
        final answer = data['answer'] ?? 'Sorry, I could not understand your question.';

        _messages.add(ChatMessage(content: answer, isUser: false));
        _suggestions = (data['suggestions'] as List?)?.map((e) => e.toString()).toList() ?? [];
      }
    } catch (e) {
      _messages.add(ChatMessage(
        content: 'Sorry, I am having trouble connecting to the server. Please check your internet connection and try again.',
        isUser: false,
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  void startNewSession() {
    _messages = [];
    _suggestions = [];
    notifyListeners();
  }
}
