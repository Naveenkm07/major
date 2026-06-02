import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isEnglish = true; // For the UI toggle

  void _getOtp() {
    // For demo purposes, immediately navigate to home to show off the UI flow
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // The nice off-white from Figma
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'KrushikaDhara',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'ಸ್ಮಾರ್ಟ್ ಕೃಷಿ ಸಹಚರ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Language Selection
              const Text(
                'Choose Language / ಭಾಷೆ',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isEnglish = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isEnglish ? AppTheme.primaryGreen : Colors.white,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          border: Border.all(color: _isEnglish ? AppTheme.primaryGreen : Colors.grey.shade300),
                        ),
                        child: Text(
                          'English',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isEnglish ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isEnglish = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: !_isEnglish ? AppTheme.primaryGreen : Colors.white,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                          border: Border.all(color: !_isEnglish ? AppTheme.primaryGreen : Colors.grey.shade300),
                        ),
                        child: Text(
                          'ಕನ್ನಡ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isEnglish ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Phone Input
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.phone_outlined, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('+91', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '98765 43210',
                          hintStyle: TextStyle(color: Colors.black87, fontSize: 16, letterSpacing: 1.5),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          filled: false,
                        ),
                        style: const TextStyle(fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Get OTP Button
              ElevatedButton(
                onPressed: _getOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Get OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              
              const SizedBox(height: 24),
              
              // Terms
              const Text(
                'By continuing you agree to our Terms &\nPrivacy',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
