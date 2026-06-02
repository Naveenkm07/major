import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../config/theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _scrollController = ScrollController();
  bool _isListening = false;

  void _toggleListening() {
    setState(() => _isListening = !_isListening);
    if (!_isListening) {
      // Simulate sending a voice message when they stop "listening"
      Provider.of<ChatProvider>(context, listen: false).sendMessage("ನನ್ನ ಟೊಮ್ಯಾಟೋ ಎಲೆಗಳಲ್ಲಿ ಹಳದಿ ಚುಕ್ಕೆಗಳಿವೆ.");
      Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ─── Header ────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            color: AppTheme.primaryGreen,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.eco, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Assistant', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        const Text('Online · Kannada', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.white),
              ],
            ),
          ),

          // ─── Messages Area ────────────────────
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, chat, __) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: chat.messages.length + (_isListening || chat.isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == chat.messages.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: _isListening ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (_isListening) ...[
                              Row(
                                children: [
                                  Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(width: 4),
                                  Container(width: 4, height: 24, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(width: 4),
                                  Container(width: 4, height: 12, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(width: 8),
                                  const Text('Listening...', style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
                                    SizedBox(width: 10),
                                    Text('Thinking...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      );
                    }

                    final msg = chat.messages[i];
                    return _ChatBubble(content: msg.content, isUser: msg.isUser);
                  },
                );
              },
            ),
          ),

          // ─── Suggestion Chips ─────────────────
          Consumer<ChatProvider>(
            builder: (_, chat, __) {
              if (chat.suggestions.isEmpty || chat.isLoading) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.only(bottom: 16),
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: chat.suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(s, style: const TextStyle(fontSize: 14)),
                      backgroundColor: Colors.grey.shade200,
                      onPressed: () => Provider.of<ChatProvider>(context, listen: false).sendMessage(s),
                    ),
                  )).toList(),
                ),
              );
            },
          ),

          // ─── Voice Input Bar ────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _isListening ? AppTheme.accentDark : AppTheme.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (_isListening) BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 20, spreadRadius: 10)
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Tap and speak in Kannada', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const _ChatBubble({required this.content, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey.shade200 : AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.black87 : Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
