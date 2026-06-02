import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final String _helpLineNumber = '+919591502209';
  final String _supportEmail = 'support@krushikadhara.com';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch phone dialer.');
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    // Remove '+' and spaces for WhatsApp URL
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final Uri launchUri = Uri.parse('https://wa.me/$cleanNumber?text=Hello%20KrushikaDhara%20Support,%20I%20need%20help');
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not launch WhatsApp. Is it installed?');
    }
  }

  Future<void> _sendEmail() async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=App Support Request&body=Please describe your issue here...',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch email client.');
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
                  const Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
                        const Text(
                          'Need help in Kannada?',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Talk to our AI assistant anytime, free.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
                          child: const Text('Start Voice Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          title: 'Call Helpline',
                          subtitle: '$_helpLineNumber\nAvailable 24x7',
                          onTap: () => _makePhoneCall(_helpLineNumber),
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.message_outlined,
                          title: 'WhatsApp',
                          subtitle: 'Instant Chat\nAvg reply 5 min',
                          onTap: () => _launchWhatsApp(_helpLineNumber),
                          color: const Color(0xFF25D366), // WhatsApp Green
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Support
                  _buildActionCard(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: _supportEmail,
                    onTap: _sendEmail,
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
                            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Icon(Icons.help_outline, color: Colors.grey.shade400, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFaqTile(
                          question: 'How do I scan a crop disease?',
                          answer: 'Go to the "Scan" tab at the bottom of the screen. Tap the camera icon to take a photo of the affected leaf, or upload one from your gallery. The AI will analyze the image and provide treatment options.',
                        ),
                        _buildFaqTile(
                          question: 'How does the Voice Assistant work?',
                          answer: 'Tap the yellow microphone button on the home screen. You can speak in Kannada, Hindi, or English. Ask things like "What is the price of tomatoes today?" or "How to apply urea?"',
                        ),
                        _buildFaqTile(
                          question: 'When are Mandi prices updated?',
                          answer: 'Mandi prices are pulled directly from the Government of India (Data.gov.in) API and are updated daily at 6:00 AM IST.',
                        ),
                        _buildFaqTile(
                          question: 'How do I apply for a subsidy?',
                          answer: 'Go to the "Govt Schemes" section. Browse the available central and state schemes. Tap "View Details" on a scheme to check eligibility and find the official application link.',
                        ),
                        _buildFaqTile(
                          question: 'Is my farm data kept private?',
                          answer: 'Yes, your data is securely stored and is only used to provide personalized weather alerts, crop calendars, and relevant scheme notifications.',
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
