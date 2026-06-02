import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class SmartNotificationsScreen extends StatefulWidget {
  const SmartNotificationsScreen({super.key});

  @override
  State<SmartNotificationsScreen> createState() => _SmartNotificationsScreenState();
}

class _SmartNotificationsScreenState extends State<SmartNotificationsScreen> {
  final _apiService = ApiService();
  bool _isSaving = false;

  // Notification states
  bool _mandiAlerts = true;
  bool _weatherSmsAlerts = false;
  
  // Custom price thresholds
  final List<Map<String, dynamic>> _priceThresholds = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user != null && user.farmDetails?.crops != null) {
      for (var crop in user.farmDetails!.crops!) {
        _priceThresholds.add({
          'name': crop.name,
          'enabled': false,
          'price': 50.0,
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      // In a real app, you'd send this to the backend
      // await _apiService.put('/auth/update-notifications', {...});
      
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences updated!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Smart Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Weather Alerts Section ──────────
            _buildSectionHeader('Weather Alerts'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildToggleRow(
                    'Heavy Rain SMS Alerts', 
                    'Receive an SMS if heavy rain is predicted for tomorrow.',
                    _weatherSmsAlerts,
                    (val) => setState(() => _weatherSmsAlerts = val),
                    Icons.thunderstorm_outlined,
                    Colors.blue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Price Alerts Section ────────────
            _buildSectionHeader('Smart Price Alerts'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Get notified when market prices reach your targets.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            
            if (_priceThresholds.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('Add crops in your profile to set price alerts.', textAlign: TextAlign.center),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _priceThresholds.length,
                itemBuilder: (context, index) {
                  final item = _priceThresholds[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.trending_up, color: AppTheme.primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Alert for ${item['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                            Switch(
                              value: item['enabled'],
                              onChanged: (val) => setState(() => item['enabled'] = val),
                              activeColor: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                        if (item['enabled']) ...[
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Text('Notify me if price goes above:'),
                              const Spacer(),
                              Container(
                                width: 80,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      prefixText: '₹',
                                    ),
                                    onChanged: (val) => item['price'] = double.tryParse(val) ?? 0,
                                    controller: TextEditingController(text: item['price'].toStringAsFixed(0)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('/kg', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),

            // ─── Save Button ─────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryGreen,
        ),
      ],
    );
  }
}
