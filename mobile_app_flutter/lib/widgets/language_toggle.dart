/// Kannada ↔ English toggle button for the app bar or settings.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/locale.dart';
import '../config/theme.dart';

class LanguageToggle extends StatelessWidget {
  final bool isDarkBackground;
  const LanguageToggle({super.key, this.isDarkBackground = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLocale>(
      builder: (_, locale, __) {
        return GestureDetector(
          onTap: () => locale.toggleLanguage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkBackground ? Colors.white : AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkBackground ? Colors.white : AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate_rounded, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 4),
                Text(
                  _getLangLabel(locale.languageCode),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLangLabel(String code) {
    switch (code) {
      case 'kn': return 'ಕ';
      case 'hi': return 'हि';
      default: return 'EN';
    }
  }
}
