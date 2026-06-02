import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _titleKnCtrl = TextEditingController();
  final _messageKnCtrl = TextEditingController();
  
  String _selectedType = 'system';
  
  final List<String> _types = [
    'system',
    'disease_alert',
    'market_update',
    'weather_warning',
    'scheme_update',
    'community_activity',
    'reminder'
  ];

  Future<void> _sendBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await ApiService().sendAdminNotification({
        'title': _titleCtrl.text,
        'message': _messageCtrl.text,
        'title_kn': _titleKnCtrl.text,
        'message_kn': _messageKnCtrl.text,
        'type': _selectedType,
      });

      if (res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Broadcast sent successfully!')),
          );
          // Clear form
          _titleCtrl.clear();
          _messageCtrl.clear();
          _titleKnCtrl.clear();
          _messageKnCtrl.clear();
          
          // Refresh notifications if admin is testing
          Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
        }
      } else {
        throw Exception(res['message'] ?? 'Failed to send broadcast');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin: Send Broadcast', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── English Section ───
              const Text('English Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title (English)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message (English)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // ─── Kannada Section ───
              const Text('Kannada Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleKnCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title (Kannada - Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageKnCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message (Kannada - Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ─── Type Section ───
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Notification Type',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _sendBroadcast,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Broadcast', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
