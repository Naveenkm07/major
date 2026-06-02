import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../crop_disease/disease_detection_screen.dart';
import '../market/market_prices_screen.dart';
import '../community/community_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../../services/location_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';
import '../../providers/weather_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/calendar_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

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
    _requestLocationAndData();
  }

  Future<void> _requestLocationAndData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final loc = await LocationService.getCurrentLocation();
    if (loc != null && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.updateProfile(loc); 
      
      if (mounted) {
        Provider.of<WeatherProvider>(context, listen: false).fetchWeather(loc['village'] ?? 'Bengaluru');
        // Pre-fetch market prices for home screen
        Provider.of<MarketProvider>(context, listen: false).fetchPrices(state: loc['district'] ?? 'Mandya');
      }
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
      backgroundColor: AppTheme.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.document_scanner_rounded), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Market'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () => Navigator.pushNamed(context, '/voice-assistant'),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? auth.user?.name ?? 'Farmer';
    final location = auth.user?.location?.district ?? 'Mandya';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dark green background block
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Namaskara 🙏', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const LanguageToggle(isDarkBackground: true),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Overlapping Weather Widget
              Positioned(
                top: 140,
                left: 20,
                right: 20,
                child: _buildWeatherWidget(context, location),
              ),
            ],
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for overlapping widget

        // Quick Actions Section
        SliverToBoxAdapter(
          child: _buildQuickActions(context),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // This Week's Tasks Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocale.t(context, 'todays_tips'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/crop-calendar'),
                  child: const Text('View all', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: _buildTasksList(context),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(AppLocale.t(context, 'market_prices').replaceAll('\n', ' '), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        SliverToBoxAdapter(
          child: _buildMandiPricesScroll(context),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
      ],
    );
  }

  Widget _buildWeatherWidget(BuildContext context, String location) {
    return Consumer<WeatherProvider>(
      builder: (context, weather, _) {
        final w = weather.currentWeather;
        final temp = w?['temperature'] ?? '28';
        final desc = w?['description'] ?? 'Sunny';
        final moisture = w?['humidity'] ?? '62';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$location • ${AppLocale.t(context, 'refresh')}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$temp°', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, height: 1.0)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(desc, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.water_drop_outlined, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text('${AppLocale.t(context, 'humidity')}: $moisture%', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.wb_sunny_rounded, color: AppTheme.accent, size: 64),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'title': AppLocale.t(context, 'pest_detection'), 'icon': Icons.camera_alt_rounded, 'color': Colors.red, 'route': '/disease-detection'},
      {'title': AppLocale.t(context, 'market_prices'), 'icon': Icons.trending_up_rounded, 'color': Colors.blue, 'route': '/market-prices'},
      {'title': AppLocale.t(context, 'crop_calendar'), 'icon': Icons.calendar_month_rounded, 'color': Colors.green, 'route': '/crop-calendar'},
      {'title': AppLocale.t(context, 'equipment_rental'), 'icon': Icons.agriculture_rounded, 'color': Colors.teal, 'route': '/equipment-rental'},
      {'title': AppLocale.t(context, 'crop_insurance'), 'icon': Icons.security_rounded, 'color': Colors.orange, 'route': '/insurance'},
      {'title': AppLocale.t(context, 'govt_schemes'), 'icon': Icons.account_balance_rounded, 'color': Colors.purple, 'route': '/schemes'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocale.t(context, 'quick_actions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              final MaterialColor color = action['color'];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, action['route']),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.shade100, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(action['icon'], color: color.shade700, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        action['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _TaskCard(
            icon: Icons.water_drop_outlined,
            iconColor: Colors.blue,
            title: AppLocale.t(context, 'irrigation_tip'),
            time: AppLocale.t(context, 'irrigation_desc'),
            isCompleted: true,
          ),
          const SizedBox(height: 12),
          _TaskCard(
            icon: Icons.eco_outlined,
            iconColor: AppTheme.primaryGreen,
            title: AppLocale.t(context, 'weather_tip'),
            time: AppLocale.t(context, 'weather_desc'),
            isCompleted: false,
          ),
          const SizedBox(height: 12),
          _TaskCard(
            icon: Icons.bug_report_outlined,
            iconColor: Colors.orange.shade700,
            title: AppLocale.t(context, 'pest_alert'),
            time: AppLocale.t(context, 'pest_desc'),
            isCompleted: false,
            isWarning: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMandiPricesScroll(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          _MandiCard(commodity: 'Tomato', price: '₹28', trend: '▲ 4%', isUp: true),
          SizedBox(width: 12),
          _MandiCard(commodity: 'Ragi', price: '₹42', trend: '▲ 2%', isUp: true),
          SizedBox(width: 12),
          _MandiCard(commodity: 'Onion', price: '₹19', trend: '▼ 1%', isUp: false),
          SizedBox(width: 12),
          _MandiCard(commodity: 'Potato', price: '₹22', trend: '▲ 1%', isUp: true),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final bool isCompleted;
  final bool isWarning;

  const _TaskCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.isCompleted,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWarning ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isWarning ? Colors.orange : iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen)
          else
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}

class _MandiCard extends StatelessWidget {
  final String commodity;
  final String price;
  final String trend;
  final bool isUp;

  const _MandiCard({
    required this.commodity,
    required this.price,
    required this.trend,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(commodity, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$price/', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Text('kg', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            ),

          const SizedBox(height: 8),
          Text(trend, style: TextStyle(color: isUp ? AppTheme.primaryGreen : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
