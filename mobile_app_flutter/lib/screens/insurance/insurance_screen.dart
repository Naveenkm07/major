import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'crop_insurance')),
        actions: const [LanguageToggle(), SizedBox(width: 10)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Status Card ──────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.security_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(AppLocale.t(context, 'pmfby_tracker'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Deadlines ────────────────────────
            _ActionTile(
              icon: Icons.event_available_rounded,
              title: AppLocale.t(context, 'check_deadline'),
              subtitle: 'Kharif 2026: Aug 15 | Rabi 2026: Dec 31',
              color: Colors.orange,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // ─── Premium Calc ─────────────────────
            _ActionTile(
              icon: Icons.calculate_rounded,
              title: AppLocale.t(context, 'premium_calc'),
              subtitle: 'Estimate your insurance cost per acre',
              color: Colors.blue,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // ─── File Claim ───────────────────────
            _ActionTile(
              icon: Icons.report_problem_rounded,
              title: AppLocale.t(context, 'file_claim'),
              subtitle: 'Report crop damage within 72 hours',
              color: AppTheme.error,
              onTap: () {},
            ),
            
            const SizedBox(height: 32),
            Text(AppLocale.t(context, 'govt_schemes'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Pradhan Mantri Fasal Bima Yojana (PMFBY) protects farmers from financial loss due to crop failure caused by natural disasters.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}
