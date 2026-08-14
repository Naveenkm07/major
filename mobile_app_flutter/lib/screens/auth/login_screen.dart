import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../core/locale.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  bool _acceptedTerms = false;
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        showDialog(
          context: context,
          builder: (context) {
            final isKannada = Provider.of<AppLocale>(context, listen: false).isKannada;
            return AlertDialog(
              title: Text(AppLocale.t(context, 'terms_privacy_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Text(AppLocale.t(context, 'terms_privacy_content')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocale.t(context, 'ok'), style: const TextStyle(color: AppTheme.primaryGreen)),
                ),
              ],
            );
          },
        );
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _getOtp() async {
    if (_phoneCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    String phoneNumber = '+91${_phoneCtrl.text.trim()}';

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: phoneNumber,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamed(context, '/otp', arguments: {
          'phoneNumber': phoneNumber,
        });
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
    final isKannada = Provider.of<AppLocale>(context).isKannada;
    
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
                            AppLocale.t(context, 'welcome'),
                            style: !isKannada
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
                            AppLocale.t(context, 'login'),
                            style: !isKannada
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
                            AppLocale.t(context, 'phone'),
                            style: !isKannada
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
                                      hintText: AppLocale.t(context, 'phone_hint'),
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

                          // ── Terms & Privacy Text ──────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptedTerms = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.primaryGreen,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: !isKannada
                                          ? const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5, fontFamily: 'Roboto')
                                          : GoogleFonts.notoSansKannada(color: Colors.grey, fontSize: 13, height: 1.5),
                                      children: [
                                        TextSpan(text: AppLocale.t(context, 'agree_to')),
                                        TextSpan(
                                          text: AppLocale.t(context, 'terms_privacy_link'),
                                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                          recognizer: _termsRecognizer,
                                        ),
                                        if (isKannada)
                                          TextSpan(text: AppLocale.t(context, 'agree_to_suffix')),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Get OTP Button ──────────────
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primaryGreen))
                              : ElevatedButton(
                                  onPressed: () {
                                    if (!_acceptedTerms) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocale.t(context, 'accept_terms_error'))),
                                      );
                                      return;
                                    }
                                    _getOtp();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    AppLocale.t(context, 'get_otp'),
                                    style: !isKannada
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
                          
                          const SizedBox(height: 24),
                          
                          // ── OR Divider ──────────────────
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  AppLocale.t(context, 'or'),
                                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Google Sign In Button ───────
                          ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (!_acceptedTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocale.t(context, 'accept_terms_error'))),
                                );
                                return;
                              }
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              final success = await auth.supabaseGoogleSignIn();
                              if (success && mounted) {
                                Navigator.pushReplacementNamed(context, '/home');
                              } else if (!success && mounted && auth.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(auth.error!)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.05),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                  height: 24,
                                  width: 24,
                                  placeholderBuilder: (context) => const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocale.t(context, 'continue_google'),
                                  style: !isKannada 
                                      ? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                                      : GoogleFonts.notoSansKannada(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
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
                onTap: () => context.read<AppLocale>().toggleLanguage(),
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
                        !isKannada ? 'ಕ' : 'A',
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
