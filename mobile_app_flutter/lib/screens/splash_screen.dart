import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.checkAuth();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, auth.isAuthenticated ? '/home' : '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌾', style: TextStyle(fontSize: 64)),
                ),
                const SizedBox(height: 24),
                const Text('KrushikaDhara', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Smart Farming Companion', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 40),
                SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
