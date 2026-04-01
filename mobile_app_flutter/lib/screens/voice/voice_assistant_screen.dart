/// Kannada Voice Assistant Screen
/// Farmers can speak questions and hear AI responses.
///
/// Flow:
///   1. Tap mic → STT captures speech (Kannada/English)
///   2. Text sent to AI chatbot API
///   3. AI response displayed + TTS speaks it back
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/chat_provider.dart';
import '../../services/voice_assistant_service.dart';
import '../../core/locale.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _lastQuestion = '';
  String _lastAnswer = '';
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startVoiceInput() async {
    final voice = Provider.of<VoiceAssistantService>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);

    _pulseController.repeat(reverse: true);

    final recognized = await voice.startListening();
    _pulseController.stop();
    _pulseController.reset();

    if (recognized == null || recognized.isEmpty) return;

    setState(() {
      _lastQuestion = recognized;
      _processing = true;
    });

    // Send to AI chatbot
    await chat.sendMessage(recognized);

    // Get last bot response
    final messages = chat.messages;
    final botResponse = messages.isNotEmpty && !messages.last.isUser
        ? messages.last.content
        : 'Sorry, I could not get a response.';

    setState(() {
      _lastAnswer = botResponse;
      _processing = false;
    });

    // Speak the response
    await voice.speak(botResponse);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppLocale>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(locale.tr('ai_assistant')),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate_rounded),
            onSelected: (code) {
              locale.setLanguage(code);
              Provider.of<VoiceAssistantService>(context, listen: false)
                  .setLanguage(code);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
              const PopupMenuItem(value: 'hi', child: Text('हिंदी')),
              const PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: Consumer<VoiceAssistantService>(
        builder: (_, voice, __) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ─── Bot Avatar ─────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryGreen.withOpacity(0.15),
                              AppTheme.primaryGreen.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Icon(
                          voice.isSpeaking
                              ? Icons.volume_up_rounded
                              : Icons.smart_toy_rounded,
                          size: 56,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Status Text ────────────────────
                      Text(
                        voice.isListening
                            ? locale.isKannada
                                ? 'ಕೇಳುತ್ತಿದ್ದೇನೆ... ಮಾತನಾಡಿ'
                                : 'Listening... speak now'
                            : voice.isSpeaking
                                ? locale.isKannada
                                    ? 'ಉತ್ತರ ಹೇಳುತ್ತಿದ್ದೇನೆ...'
                                    : 'Speaking answer...'
                                : _processing
                                    ? locale.tr('thinking')
                                    : locale.isKannada
                                        ? 'ಮೈಕ್ ಬಟನ್ ಒತ್ತಿ ಪ್ರಶ್ನೆ ಕೇಳಿ'
                                        : 'Tap the mic to ask a question',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: voice.isListening
                              ? AppTheme.primaryGreen
                              : AppTheme.textSecondary,
                        ),
                      ),

                      // ─── Recognized Speech ─────────────
                      if (_lastQuestion.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _ResultCard(
                          icon: Icons.record_voice_over_rounded,
                          iconColor: AppTheme.marketBlue,
                          label: locale.isKannada ? 'ನೀವು ಕೇಳಿದ್ದು:' : 'You asked:',
                          content: _lastQuestion,
                        ),
                      ],

                      // ─── AI Response ────────────────────
                      if (_lastAnswer.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _ResultCard(
                          icon: Icons.smart_toy_rounded,
                          iconColor: AppTheme.primaryGreen,
                          label: locale.isKannada ? 'AI ಉತ್ತರ:' : 'AI Answer:',
                          content: _lastAnswer,
                          onSpeak: () =>
                              Provider.of<VoiceAssistantService>(context, listen: false)
                                  .speak(_lastAnswer),
                        ),
                      ],

                      // ─── Quick Suggestions ──────────────
                      if (_lastQuestion.isEmpty) ...[
                        const SizedBox(height: 40),
                        Text(
                          locale.isKannada ? 'ಉದಾಹರಣೆ ಪ್ರಶ್ನೆಗಳು:' : 'Example questions:',
                          style: TextStyle(color: AppTheme.textHint, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        _SuggestionChip(
                          text: locale.isKannada
                              ? '🌿 ಟೊಮೇಟೋ ಎಲೆ ಹಳದಿ ಆಗಿದೆ'
                              : '🌿 My tomato leaves turned yellow',
                        ),
                        _SuggestionChip(
                          text: locale.isKannada
                              ? '💰 ಇಂದಿನ ಮಾರುಕಟ್ಟೆ ಬೆಲೆ'
                              : '💰 Today\'s market price for rice',
                        ),
                        _SuggestionChip(
                          text: locale.isKannada
                              ? '🏛️ ಸರ್ಕಾರಿ ಯೋಜನೆ ಮಾಹಿತಿ'
                              : '🏛️ Government scheme for farmers',
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ─── Mic Button ────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stop button (when listening)
                    if (voice.isListening || voice.isSpeaking)
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: FloatingActionButton(
                          heroTag: 'stop',
                          mini: true,
                          backgroundColor: AppTheme.error,
                          onPressed: () {
                            if (voice.isListening) voice.stopListening();
                            if (voice.isSpeaking) voice.stopSpeaking();
                          },
                          child: const Icon(Icons.stop_rounded, color: Colors.white),
                        ),
                      ),

                    // Main mic button
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, child) {
                        final scale = 1.0 + (_pulseController.value * 0.15);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: FloatingActionButton(
                          heroTag: 'mic',
                          backgroundColor: voice.isListening
                              ? AppTheme.error
                              : AppTheme.primaryGreen,
                          onPressed: _processing
                              ? null
                              : () {
                                  if (voice.isListening) {
                                    voice.stopListening();
                                  } else {
                                    _startVoiceInput();
                                  }
                                },
                          child: Icon(
                            voice.isListening
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String content;
  final VoidCallback? onSpeak;

  const _ResultCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.content,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textHint, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (onSpeak != null)
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  color: iconColor,
                  onPressed: onSpeak,
                  tooltip: 'Listen',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  const _SuggestionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
