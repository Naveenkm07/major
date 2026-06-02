import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final String _helpLineNumber = '+919591502209';
  final String _supportEmail = 'support@krushikadhara.com';

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar(AppLocale.t(context, 'error_phone'));
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, BuildContext context) async {
    // Remove '+' and spaces for WhatsApp URL
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final Uri launchUri = Uri.parse('https://wa.me/$cleanNumber?text=Hello%20KrushikaDhara%20Support,%20I%20need%20help');
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar(AppLocale.t(context, 'error_whatsapp'));
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=App Support Request&body=Please describe your issue here...',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar(AppLocale.t(context, 'error_email'));
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(AppLocale.t(context, 'help_support'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── AI Assistant Banner ───────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.eco_outlined, color: Colors.white, size: 32),
                        const SizedBox(height: 16),
                        Text(
                          AppLocale.t(context, 'need_help_kannada'),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocale.t(context, 'talk_to_ai'),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/voice-assistant'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                          ),
                          child: Text(AppLocale.t(context, 'start_voice_chat'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // ─── Support Actions ──────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.phone_outlined,
                          title: AppLocale.t(context, 'call_helpline'),
                          subtitle: '$_helpLineNumber\n${AppLocale.t(context, 'available_24x7')}',
                          onTap: () => _makePhoneCall(_helpLineNumber, context),
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.message_outlined,
                          title: AppLocale.t(context, 'whatsapp'),
                          subtitle: '${AppLocale.t(context, 'instant_chat')}\n${AppLocale.t(context, 'avg_reply')}',
                          onTap: () => _launchWhatsApp(_helpLineNumber, context),
                          color: const Color(0xFF25D366), // WhatsApp Green
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Support
                  _buildActionCard(
                    icon: Icons.email_outlined,
                    title: AppLocale.t(context, 'email_support'),
                    subtitle: _supportEmail,
                    onTap: () => _sendEmail(context),
                    color: Colors.blue,
                    isHorizontal: true,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // ─── FAQ Section ────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocale.t(context, 'faq_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Icon(Icons.help_outline, color: Colors.grey.shade400, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFaqTile(
                          question: AppLocale.t(context, 'faq_q1'),
                          answer: AppLocale.t(context, 'faq_a1'),
                        ),
                        _buildFaqTile(
                          question: AppLocale.t(context, 'faq_q2'),
                          answer: AppLocale.t(context, 'faq_a2'),
                        ),
                        _buildFaqTile(
                          question: AppLocale.t(context, 'faq_q3'),
                          answer: AppLocale.t(context, 'faq_a3'),
                        ),
                        _buildFaqTile(
                          question: AppLocale.t(context, 'faq_q4'),
                          answer: AppLocale.t(context, 'faq_a4'),
                        ),
                        _buildFaqTile(
                          question: AppLocale.t(context, 'faq_q5'),
                          answer: AppLocale.t(context, 'faq_a5'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap,
    required Color color,
    bool isHorizontal = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: isHorizontal 
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.4)),
              ],
            ),
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(question, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
        iconColor: AppTheme.primaryGreen,
        collapsedIconColor: Colors.grey.shade400,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
