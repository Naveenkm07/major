import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/location_service.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp(dynamic authData, bool isEnglish) async {
    if (_otpCtrl.text.length < 6) return;

    setState(() => _isLoading = true);
    
    try {
      if (kIsWeb) {
        final ConfirmationResult result = authData as ConfirmationResult;
        await result.confirm(_otpCtrl.text.trim());
      } else {
        final String verificationId = authData as String;
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: _otpCtrl.text.trim(),
        );
        // Sign the user in
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      
      // Navigate to Home on success
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Sync with Node.js backend
          if (user.phoneNumber != null) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.firebaseSync(user.phoneNumber!);
          }

          if (user.displayName == null || user.displayName!.isEmpty) {
            Navigator.pushNamedAndRemoveUntil(context, '/setup-profile', (route) => false, arguments: isEnglish);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Invalid OTP code')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get arguments map from LoginScreen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final authData = args?['authData'];
    final bool isEnglish = args?['isEnglish'] ?? true;
    
    if (authData == null) {
      return const Scaffold(body: Center(child: Text("Error: No verification ID provided.")));
    }

    // Translations
    final String title = isEnglish ? 'Enter OTP' : 'OTP ನಮೂದಿಸಿ';
    final String subtitle = isEnglish 
        ? 'We have sent a 6-digit code to your phone number.' 
        : 'ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆಗೆ ನಾವು 6-ಅಂಕಿಯ ಕೋಡ್ ಕಳುಹಿಸಿದ್ದೇವೆ.';
    final String buttonText = isEnglish ? 'Verify & Login' : 'ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಲಾಗಿನ್ ಮಾಡಿ';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: isEnglish 
                    ? const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      )
                    : GoogleFonts.notoSansKannada(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: isEnglish 
                    ? const TextStyle(fontSize: 16, color: Colors.grey)
                    : GoogleFonts.notoSansKannada(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              
              // OTP Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: "------",
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : ElevatedButton(
                      onPressed: () => _verifyOtp(authData, isEnglish),
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
