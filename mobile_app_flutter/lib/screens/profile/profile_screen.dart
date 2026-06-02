import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../services/api_service.dart';
import '../../services/weather_service.dart';
import '../../services/location_service.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import './edit_profile_screen.dart';
import './my_crops_screen.dart';
import './smart_notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  final _weatherService = WeatherService();
  
  UserModel? _user;
  Map<String, dynamic>? _weather;
  bool _isLoading = true;
  bool _isUpdatingLocation = false;
  
  bool _mandiAlerts = true;
  bool _diseaseAlerts = true;
  bool _weatherAlerts = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.checkAuth();
      _user = auth.user;
      
      if (_user?.location?.district != null) {
        try {
          _weather = await _weatherService.getWeather(_user!.location!.district!);
        } catch (e) {
          debugPrint('Weather fetch error: $e');
        }
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppLocale>(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Hero Section ────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 40),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            Text(AppLocale.t(context, 'profile'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (_user != null)
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
                              );
                              if (result == true) _fetchData();
                            },
                            child: Text(AppLocale.t(context, 'edit'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.person_outline, size: 50, color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    Text(_user?.name ?? 'Guest User', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_user?.phone ?? 'Please log in', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    
                    if (_user == null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Login / Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],

                    if (_weather != null) ...[
                      const SizedBox(height: 24),
                      _buildWeatherWidget(context),
                    ],
                  ],
                ),
              ),
              
              // ─── Content ──────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farming Insights
                    Text(AppLocale.t(context, 'farming_insights'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    _buildInsightsGrid(context),
                    
                    const SizedBox(height: 24),

                    // My Crops
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocale.t(context, 'my_crops'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        GestureDetector(
                          onTap: () async {
                            if (_user != null) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyCropsScreen(currentCrops: _user!.farmDetails?.crops ?? []),
                                ),
                              );
                              if (result == true) _fetchData();
                            }
                          },
                          child: Row(
                            children: [
                              Text(AppLocale.t(context, 'edit'), style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit, size: 16, color: AppTheme.primaryGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: _user?.farmDetails?.crops?.isNotEmpty == true
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: _user!.farmDetails!.crops!.map((crop) => _buildCropTag(crop.name, _getCropEmoji(crop.name))).toList(),
                            )
                          : Text(AppLocale.t(context, 'no_crops'), style: const TextStyle(color: Colors.grey)),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location
                    Text(AppLocale.t(context, 'location'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        setState(() => _isUpdatingLocation = true);
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final loc = await LocationService.getCurrentLocation();
                        if (loc != null && mounted) {
                          await auth.updateProfile(loc);
                          await _fetchData();
                        }
                        if (mounted) setState(() => _isUpdatingLocation = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Icon(Icons.my_location_rounded, color: _isUpdatingLocation ? Colors.grey : AppTheme.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _isUpdatingLocation
                                  ? Row(
                                      children: [
                                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
                                        const SizedBox(width: 10),
                                        Text(AppLocale.t(context, 'detecting'), style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                                      ],
                                    )
                                  : Text(
                                      _user?.location?.district != null
                                          ? '${AppLocale.t(context, _user!.location!.district!)}, ${AppLocale.t(context, _user!.location!.state ?? '')}'
                                          : AppLocale.t(context, 'detect_location'),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                            Icon(Icons.refresh_rounded, color: Colors.grey.shade400, size: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notifications
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocale.t(context, 'notifications'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SmartNotificationsScreen()),
                          ),
                          child: Row(
                            children: [
                              Text(AppLocale.t(context, 'edit'), style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              const Icon(Icons.settings_outlined, size: 16, color: AppTheme.primaryGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _buildNotificationToggle(AppLocale.t(context, 'mandi_alerts'), _mandiAlerts, (val) => setState(() => _mandiAlerts = val)),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          _buildNotificationToggle(AppLocale.t(context, 'disease_alerts'), _diseaseAlerts, (val) => setState(() => _diseaseAlerts = val)),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          _buildNotificationToggle(AppLocale.t(context, 'weather_updates'), _weatherAlerts, (val) => setState(() => _weatherAlerts = val)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // App Settings
                    Text(AppLocale.t(context, 'app_settings'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.language, color: Colors.blue),
                            title: Text(AppLocale.t(context, 'language'), style: const TextStyle(fontSize: 16)),
                            trailing: Text(locale.isKannada ? 'ಕನ್ನಡ' : 'English', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                            onTap: () => _showLanguageDialog(context),
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                            title: Text(AppLocale.t(context, 'admin_dashboard'), style: const TextStyle(fontSize: 16)),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            onTap: () => Navigator.pushNamed(context, '/admin-notifications'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Help & Support
                    Text(AppLocale.t(context, 'help_support'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.help_outline, color: AppTheme.primaryGreen),
                            title: Text(AppLocale.t(context, 'help_support'), style: const TextStyle(fontSize: 16, color: Colors.black87)),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            onTap: () => Navigator.pushNamed(context, '/help-support'),
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: Text(AppLocale.t(context, 'logout'), style: const TextStyle(fontSize: 16, color: Colors.red)),
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWidget(BuildContext context) {
    final temp = _weather!['main']['temp'];
    final desc = _weather!['weather'][0]['description'];
    final icon = _weather!['weather'][0]['icon'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network('https://openweathermap.org/img/wn/$icon.png', width: 40, height: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${temp.round()}°C', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(desc.toString().toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(width: 20),
          const VerticalDivider(color: Colors.white24, width: 1),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocale.t(context, 'humidity'), style: const TextStyle(color: Colors.white70, fontSize: 10)),
              const Text('72%', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(AppLocale.t(context, 'disease_scans'), '${_user?.stats?.diseaseScans ?? 0}', Icons.bug_report_outlined, Colors.orange),
        _buildStatCard(AppLocale.t(context, 'market_alerts'), '${_user?.stats?.marketAlerts ?? 0}', Icons.trending_up, Colors.blue),
        _buildStatCard(AppLocale.t(context, 'community_posts'), '${_user?.stats?.communityPosts ?? 0}', Icons.forum_outlined, Colors.purple),
        _buildStatCard(AppLocale.t(context, 'schemes_applied'), '${_user?.stats?.schemesApplied ?? 0}', Icons.assignment_outlined, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildCropTag(String label, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Text(emoji),
        ],
      ),
    );
  }

  String _getCropEmoji(String crop) {
    switch (crop.toLowerCase()) {
      case 'tomato': return '🍅';
      case 'ragi': return '🌾';
      case 'onion': return '🧅';
      case 'coconut': return '🥥';
      case 'paddy': return '🍚';
      case 'maize': return '🌽';
      case 'sugarcane': return '🎋';
      case 'cotton': return '☁️';
      default: return '🌱';
    }
  }

  Widget _buildNotificationToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primaryGreen,
            inactiveTrackColor: Colors.grey.shade300,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final locale = Provider.of<AppLocale>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocale.t(context, 'language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                locale.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('ಕನ್ನಡ (Kannada)'),
              onTap: () {
                locale.setLanguage('kn');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
