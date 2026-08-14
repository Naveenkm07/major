import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/location_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/locale.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameCtrl.text.trim()}),
      );
      
      // Fetch location immediately upon registration
      final loc = await LocationService.getCurrentLocation();
      final Map<String, dynamic> updateData = {'name': _nameCtrl.text.trim()};
      if (loc != null) {
        updateData.addAll(loc);
      }
      
      if (mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.updateProfile(updateData);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKannada = Provider.of<AppLocale>(context).isKannada;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocale.t(context, 'what_is_name'),
                style: !isKannada 
                    ? const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)
                    : GoogleFonts.notoSansKannada(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocale.t(context, 'enter_full_name'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : ElevatedButton(
                      onPressed: () => _saveProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocale.t(context, 'continue_btn'), 
                        style: !isKannada 
                            ? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                            : GoogleFonts.notoSansKannada(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
