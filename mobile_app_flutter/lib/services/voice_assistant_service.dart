/// Voice assistant service wrapping speech_to_text and flutter_tts.
/// Supports Kannada (kn-IN), Hindi (hi-IN), and English (en-IN).
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceAssistantService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool get isListening => _isListening;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  String _currentLocale = 'en-IN';
  String get currentLocale => _currentLocale;

  VoiceAssistantService() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

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

  Future<String?> startListening() async {
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        _recognizedText = 'Microphone permission denied';
        notifyListeners();
        return null;
      }

      bool available = await _speechToText.initialize();
      if (!available) {
        _recognizedText = 'Speech recognition not available.';
        notifyListeners();
        return null;
      }

      _isListening = true;
      _recognizedText = '';
      notifyListeners();

      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          notifyListeners();
        },
        localeId: _currentLocale,
      );

      // Wait until listening stops automatically (or manually)
      while (_isListening && _speechToText.isListening) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

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

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      _isSpeaking = true;
      notifyListeners();

      await _flutterTts.setLanguage(_currentLocale);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }
}
