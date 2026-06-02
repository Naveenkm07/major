import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _mandiAlerts = true;
  bool _diseaseAlerts = true;
  bool _weatherAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Hero Section ────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 40),
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline, size: 50, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ravi Kumar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('+91 98765 43210', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            
            // ─── Content ──────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Crops
                  const Text('My Crops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        _buildCropTag('Tomato', '🍅'),
                        _buildCropTag('Ragi', '🌾'),
                        _buildCropTag('Onion', '🧅'),
                        _buildCropTag('Coconut', '🥥'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Location
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppTheme.accent),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Mandya District', style: TextStyle(fontSize: 16))),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notifications
                  const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildNotificationToggle('Mandi Price Alerts', _mandiAlerts, (val) => setState(() => _mandiAlerts = val)),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildNotificationToggle('Disease Warning Alerts', _diseaseAlerts, (val) => setState(() => _diseaseAlerts = val)),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildNotificationToggle('Weather Updates', _weatherAlerts, (val) => setState(() => _weatherAlerts = val)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropTag(String label, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Text(emoji),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primaryGreen,
            inactiveTrackColor: Colors.grey.shade300,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
