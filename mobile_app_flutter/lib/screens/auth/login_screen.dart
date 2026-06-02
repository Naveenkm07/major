import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isEnglish = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  // ── Bilingual text map ─────────────────────────────────
  String get _welcomeText => _isEnglish ? 'Welcome, Farmer!' : 'ಸ್ವಾಗತ, ರೈತರೇ!';
  String get _signInText => _isEnglish ? 'Sign In' : 'ಲಾಗಿನ್ ಮಾಡಿ';
  String get _phoneLabel => _isEnglish ? 'Phone Number' : 'ಫೋನ್ ಸಂಖ್ಯೆ';
  String get _phoneHint => _isEnglish ? 'Enter phone number' : 'ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ';
  String get _termsText => _isEnglish
      ? 'By continuing you agree to our Terms & Privacy'
      : 'ಮುಂದುವರಿಯುವ ಮೂಲಕ ನೀವು ನಮ್ಮ ನಿಯಮಗಳಿಗೆ ಒಪ್ಪುತ್ತೀರಿ';
  String get _otpButtonText => _isEnglish ? 'Get OTP' : 'OTP ಪಡೆಯಿರಿ';

  Future<void> _getOtp() async {
    if (!_agreedToTerms || _phoneCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    String phoneNumber = '+91${_phoneCtrl.text.trim()}';

    try {
      if (kIsWeb) {
        ConfirmationResult confirmationResult =
            await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamed(context, '/otp', arguments: {
            'authData': confirmationResult,
            'isEnglish': _isEnglish,
          });
        }
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) Navigator.pushReplacementNamed(context, '/home');
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? 'Verification failed')),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.pushNamed(context, '/otp', arguments: {
                'authData': verificationId,
                'isEnglish': _isEnglish,
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E8), // warm off-white like the design
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main Content ───────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 80, 28, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 112),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),

                          // ── Wheat Icon ──────────────────
                          Center(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0D8),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '🌾',
                                  style: TextStyle(fontSize: 52),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Welcome Text ────────────────
                          Text(
                            _welcomeText,
                            style: _isEnglish
                                ? const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -0.5,
                                  )
                                : GoogleFonts.notoSansKannada(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _signInText,
                            style: _isEnglish
                                ? const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  )
                                : GoogleFonts.notoSansKannada(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 48),

                          // ── Phone Label ─────────────────
                          Text(
                            _phoneLabel,
                            style: _isEnglish
                                ? const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  )
                                : GoogleFonts.notoSansKannada(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                          ),
                          const SizedBox(height: 10),

                          // ── Phone Input Field ───────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, right: 8),
                                  child: Icon(Icons.phone_outlined, color: Colors.grey, size: 20),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '+91',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: _phoneHint,
                                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Expanded(child: SizedBox(height: 24)),
                          const SizedBox(height: 24),

                          // ── Terms Checkbox ──────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                onChanged: (val) =>
                                    setState(() => _agreedToTerms = val ?? false),
                                activeColor: AppTheme.primaryGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    _termsText,
                                    style: _isEnglish
                                        ? const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            height: 1.5,
                                          )
                                        : GoogleFonts.notoSansKannada(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            height: 1.5,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Get OTP Button ──────────────
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primaryGreen))
                              : ElevatedButton(
                                  onPressed: _agreedToTerms ? _getOtp : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                    disabledForegroundColor: Colors.grey.shade500,
                                  ),
                                  child: Text(
                                    _otpButtonText,
                                    style: _isEnglish
                                        ? const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )
                                        : GoogleFonts.notoSansKannada(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Language Toggle Button (top-right) ─────────
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _isEnglish = !_isEnglish),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.translate_rounded, size: 16, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 6),
                      Text(
                        _isEnglish ? 'ಕ' : 'A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
