/// Voice assistant service wrapping speech_to_text and flutter_tts.
/// Supports Kannada (kn-IN), Hindi (hi-IN), and English (en-IN).
import 'package:flutter/material.dart';

class VoiceAssistantService extends ChangeNotifier {
  // ─── STT State ────────────────────────────────────
  bool _isListening = false;
  bool get isListening => _isListening;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  double _confidence = 0.0;
  double get confidence => _confidence;

  // ─── TTS State ────────────────────────────────────
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  String _currentLocale = 'kn-IN'; // Default Kannada
  String get currentLocale => _currentLocale;

  // ─── Set language for STT + TTS ────────────────────
  void setLanguage(String langCode) {
    switch (langCode) {
      case 'kn':
        _currentLocale = 'kn-IN';
        break;
      case 'hi':
        _currentLocale = 'hi-IN';
        break;
      default:
        _currentLocale = 'en-IN';
    }
    notifyListeners();
  }

  /// Start listening for speech.
  /// Returns the recognized text when done.
  Future<String?> startListening() async {
    try {
      // Import speech_to_text dynamically
      final stt = await _getSpeechToText();
      if (stt == null) {
        _recognizedText = 'Speech recognition not available on this device.';
        notifyListeners();
        return null;
      }

      _isListening = true;
      _recognizedText = '';
      _confidence = 0.0;
      notifyListeners();

      // Simulated STT for development
      // In production, replace with actual speech_to_text plugin call:
      //
      // bool available = await stt.initialize(
      //   onStatus: (status) => _handleStatus(status),
      //   onError: (error) => _handleError(error),
      // );
      //
      // if (available) {
      //   await stt.listen(
      //     onResult: (result) {
      //       _recognizedText = result.recognizedWords;
      //       _confidence = result.confidence;
      //       notifyListeners();
      //     },
      //     localeId: _currentLocale,
      //     listenFor: const Duration(seconds: 30),
      //     pauseFor: const Duration(seconds: 3),
      //   );
      // }

      // Development placeholder - simulates a delay
      await Future.delayed(const Duration(seconds: 2));
      _isListening = false;
      notifyListeners();

      return _recognizedText.isNotEmpty ? _recognizedText : null;
    } catch (e) {
      _isListening = false;
      _recognizedText = 'Error: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    notifyListeners();
    // In production: await stt.stop();
  }

  /// Speak the response using TTS
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      _isSpeaking = true;
      notifyListeners();

      // In production, use flutter_tts:
      //
      // final tts = FlutterTts();
      // await tts.setLanguage(_currentLocale);
      // await tts.setSpeechRate(0.45); // Slower for farmers
      // await tts.setVolume(1.0);
      // await tts.setPitch(1.0);
      // await tts.speak(text);
      //
      // tts.setCompletionHandler(() {
      //   _isSpeaking = false;
      //   notifyListeners();
      // });

      // Development placeholder
      await Future.delayed(Duration(milliseconds: text.length * 50));
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    _isSpeaking = false;
    notifyListeners();
    // In production: await tts.stop();
  }

  /// Check if STT is available (placeholder)
  Future<dynamic> _getSpeechToText() async {
    // In production: return SpeechToText();
    return Object(); // Placeholder
  }
}
