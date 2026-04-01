import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../crop_disease/disease_detection_screen.dart';
import '../market/market_prices_screen.dart';
import '../community/community_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../../services/location_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';
import '../../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    // Delay slightly to ensure UI is ready
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final loc = await LocationService.getCurrentLocation();
    if (loc != null && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Update profile on backend automatically
      await auth.updateProfile(loc); 
      
      // Fetch Weather
      if (mounted) {
        Provider.of<WeatherProvider>(context, listen: false).fetchWeather(loc['village'] ?? 'Bengaluru');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📍 Location detected: ${loc['village']}, ${loc['district']}'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  final _pages = const [
    _DashboardPage(),
    DiseaseDetectionScreen(),
    MarketPricesScreen(),
    CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded), label: AppLocale.t(context, 'dashboard')),
            BottomNavigationBarItem(icon: const Icon(Icons.camera_alt_rounded), label: AppLocale.t(context, 'pest_scan')),
            BottomNavigationBarItem(icon: const Icon(Icons.trending_up_rounded), label: AppLocale.t(context, 'market')),
            BottomNavigationBarItem(icon: const Icon(Icons.people_rounded), label: AppLocale.t(context, 'community')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chatbot'),
        child: const Icon(Icons.smart_toy_rounded),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Dashboard Page
// ═══════════════════════════════════════════════════════

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  void _showFarmDetailsPopup(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    
    final areaController = TextEditingController(text: user?.farmDetails?.landArea?.toString() ?? '');
    final cropsController = TextEditingController(text: user?.farmDetails?.crops?.join(', ') ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocale.t(context, 'farm_details'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocale.t(context, 'land_area'),
                hintText: AppLocale.t(context, 'enter_area'),
                prefixIcon: const Icon(Icons.landscape_rounded, color: AppTheme.primaryGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cropsController,
              decoration: InputDecoration(
                labelText: AppLocale.t(context, 'crops_grown'),
                hintText: AppLocale.t(context, 'enter_crops'),
                prefixIcon: const Icon(Icons.eco_rounded, color: AppTheme.primaryGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Text(AppLocale.t(context, 'profile')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    onPressed: () async {
                      final data = {
                        'farmSize': double.tryParse(areaController.text),
                        'cropTypes': cropsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      };
                      await auth.updateProfile(data);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(AppLocale.t(context, 'save'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🌾 ${AppLocale.t(context, 'app_name')}', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 2),
                      Text(AppLocale.t(context, 'tagline'), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  Row(
                    children: [
                      const LanguageToggle(),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: () => _showFarmDetailsPopup(context),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryLight,
                          child: Icon(Icons.person, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Weather Card ────────────────────────
          SliverToBoxAdapter(
            child: Consumer<WeatherProvider>(
              builder: (context, weather, _) {
                if (weather.isLoading) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
                if (weather.currentWeather == null) return const SizedBox();
                
                final w = weather.currentWeather!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 15)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w['location'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                Text('${w['temperature']}°C', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                                Text(w['description']?.toString().toUpperCase() ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.2)),
                              ],
                            ),
                            const Icon(Icons.wb_cloudy_rounded, color: Colors.white, size: 48),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _WeatherInfo(label: AppLocale.t(context, 'humidity'), value: '${w['humidity']}%', icon: Icons.water_drop_rounded),
                            _WeatherInfo(label: AppLocale.t(context, 'rain_prob'), value: '${w['rain_probability']}%', icon: Icons.umbrella_rounded),
                            _WeatherInfo(label: AppLocale.t(context, 'wind_speed'), value: '${w['windSpeed']}m/s', icon: Icons.air_rounded),
                          ],
                        ),
                        if (w['recommendation'] != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb_rounded, color: Colors.yellowAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(child: Text(w['recommendation'], style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Hero Card ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadow,
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${AppLocale.t(context, 'welcome')} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    Text(AppLocale.t(context, 'crops_attention'), style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/chatbot'),
                      icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
                      label: Text(AppLocale.t(context, 'ask_ai'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, elevation: 0),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Quick Actions Label ────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(AppLocale.t(context, 'quick_actions'), style: Theme.of(context).textTheme.titleLarge),
            ),
          ),

          // ─── Feature Grid ──────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.88,
              children: [
                _FeatureCard(icon: Icons.camera_alt_rounded, label: AppLocale.t(context, 'pest_detection'), color: AppTheme.pestRed, onTap: () => Navigator.pushNamed(context, '/disease-detection')),
                _FeatureCard(icon: Icons.trending_up_rounded, label: AppLocale.t(context, 'market_prices'), color: AppTheme.marketBlue, onTap: () => Navigator.pushNamed(context, '/market-prices')),
                _FeatureCard(icon: Icons.calendar_month_rounded, label: AppLocale.t(context, 'crop_calendar'), color: AppTheme.calendarGreen, onTap: () => Navigator.pushNamed(context, '/crop-calendar')),
                _FeatureCard(icon: Icons.agriculture_rounded, label: AppLocale.t(context, 'equipment_rental'), color: AppTheme.communityTeal, onTap: () => Navigator.pushNamed(context, '/equipment-rental')),
                _FeatureCard(icon: Icons.security_rounded, label: AppLocale.t(context, 'crop_insurance'), color: AppTheme.loanOrange, onTap: () => Navigator.pushNamed(context, '/insurance')),
                _FeatureCard(icon: Icons.account_balance_rounded, label: AppLocale.t(context, 'govt_schemes'), color: AppTheme.schemePurple, onTap: () => Navigator.pushNamed(context, '/schemes')),
              ],
            ),
          ),

          // ─── Tips Section ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(AppLocale.t(context, 'todays_tips'), style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  _TipCard(
                    icon: Icons.water_drop_rounded,
                    color: AppTheme.info,
                    title: AppLocale.t(context, 'irrigation_tip'),
                    subtitle: AppLocale.t(context, 'irrigation_desc'),
                  ),
                  const SizedBox(height: 10),
                  _TipCard(
                    icon: Icons.bug_report_rounded,
                    color: AppTheme.pestRed,
                    title: AppLocale.t(context, 'pest_alert'),
                    subtitle: AppLocale.t(context, 'pest_desc'),
                  ),
                  const SizedBox(height: 10),
                  _TipCard(
                    icon: Icons.wb_sunny_rounded,
                    color: AppTheme.accent,
                    title: AppLocale.t(context, 'weather_tip'),
                    subtitle: AppLocale.t(context, 'weather_desc'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TipCard({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _WeatherInfo({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}
