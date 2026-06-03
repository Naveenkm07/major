import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/location_service.dart';
import '../../providers/auth_provider.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveProfile(bool isEnglish) async {
    if (_nameCtrl.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameCtrl.text.trim()}),
      );
      
      // Fetch location immediately upon registration
      final loc = await LocationService.getCurrentLocation();
      if (loc != null && mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.updateProfile(loc);
      }

      if (mounted) {
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
    final bool isEnglish = ModalRoute.of(context)?.settings.arguments as bool? ?? true;

    final String title = isEnglish ? 'What is your name?' : 'ನಿಮ್ಮ ಹೆಸರೇನು?';
    final String hint = isEnglish ? 'Enter your full name' : 'ನಿಮ್ಮ ಪೂರ್ಣ ಹೆಸರನ್ನು ನಮೂದಿಸಿ';
    final String buttonText = isEnglish ? 'Continue' : 'ಮುಂದುವರಿಸಿ';

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
                title,
                style: isEnglish 
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
                    hintText: hint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : ElevatedButton(
                      onPressed: () => _saveProfile(isEnglish),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonText, 
                        style: isEnglish 
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
