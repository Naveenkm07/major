import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

/// AI Chatbot Screen
/// ┌────────────────────────────────────────┐
/// │ AppBar: "AI Assistant 🤖" [Refresh]    │
/// │ ┌──────────────────────────────────┐   │
/// │ │   Empty state:                   │   │
/// │ │   🤖 Icon + Greeting             │   │
/// │ │   [Crop advice] [Pest help]      │   │
/// │ │                                  │   │
/// │ │   OR Message List:               │   │
/// │ │   ┌────────────────┐   ← User    │   │
/// │ │   │ User bubble    │             │   │
/// │ │   └────────────────┘             │   │
/// │ │       ┌────────────────┐ ← Bot   │   │
/// │ │       │ Bot bubble     │         │   │
/// │ │       └────────────────┘         │   │
/// │ │   [ Typing indicator... ]        │   │
/// │ └──────────────────────────────────┘   │
/// │ [ Suggestion chips scrollable ]       │
/// │ ┌──────────────────────────┐ [Send]   │
/// │ │ Text input               │         │
/// │ └──────────────────────────┘         │
/// └────────────────────────────────────────┘
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage([String? text]) {
    final msg = (text ?? _messageController.text).trim();
    if (msg.isEmpty) return;
    _messageController.clear();

    Provider.of<ChatProvider>(context, listen: false).sendMessage(msg);

    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
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
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'ai_assistant')),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'New conversation',
            onPressed: () => Provider.of<ChatProvider>(context, listen: false).startNewSession(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Messages Area ────────────────────
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, chat, __) {
                if (chat.messages.isEmpty) return _EmptyState(onSuggestionTap: _sendMessage);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    // Typing indicator
                    if (i == chat.messages.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
                                  const SizedBox(width: 10),
                                  Text(AppLocale.t(context, 'thinking'), style: TextStyle(color: AppTheme.textHint, fontSize: 13)),
                                ],
                              ),
                            ),
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
                height: 44,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: chat.suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.08),
                      onPressed: () => _sendMessage(s),
                    ),
                  )).toList(),
                ),
              );
            },
          ),

          // ─── Input Bar ────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: AppLocale.t(context, 'ask_farming'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppTheme.surfaceVariant,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final void Function(String) onSuggestionTap;

  const _EmptyState({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.chatIndigo.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.smart_toy_rounded, size: 56, color: AppTheme.chatIndigo.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text(AppLocale.t(context, 'greeting'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(AppLocale.t(context, 'ask_anything'), style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _QuickChip(label: '🌾 ${AppLocale.t(context, 'pest_detection')}', onTap: () => onSuggestionTap('Give me crop advice')),
                _QuickChip(label: '🐛 ${AppLocale.t(context, 'pest_detection')}', onTap: () => onSuggestionTap('How to control pests')),
                _QuickChip(label: '📈 ${AppLocale.t(context, 'market_prices')}', onTap: () => onSuggestionTap('What are today\'s market prices')),
                _QuickChip(label: '🏛️ ${AppLocale.t(context, 'govt_schemes')}', onTap: () => onSuggestionTap('Tell me about government schemes')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      backgroundColor: AppTheme.surfaceVariant,
      onPressed: onTap,
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
          bottom: 2,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryGreen : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          boxShadow: isUser ? null : AppTheme.softShadow,
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : AppTheme.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
