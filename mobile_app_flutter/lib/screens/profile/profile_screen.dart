import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/weather_service.dart';
import '../../services/location_service.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import './edit_profile_screen.dart';

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
  String _language = 'English';

  final Map<String, Map<String, String>> _translations = {
    'English': {
      'profile': 'Profile',
      'edit': 'Edit',
      'farming_insights': 'Farming Insights',
      'disease_scans': 'Disease Scans',
      'market_alerts': 'Market Alerts',
      'community_posts': 'Community Posts',
      'schemes_applied': 'Schemes Applied',
      'my_crops': 'My Crops',
      'location': 'Location',
      'notifications': 'Notifications',
      'mandi_alerts': 'Mandi Price Alerts',
      'disease_alerts': 'Disease Warning Alerts',
      'weather_updates': 'Weather Updates',
      'app_settings': 'App Settings',
      'language': 'Language',
      'admin_dashboard': 'Admin Dashboard',
      'help_support': 'Help & Support',
      'logout': 'Logout',
      'no_crops': 'No crops added yet.',
      'humidity': 'Humidity',
      'detect_location': 'Tap to detect location',
      'detecting': 'Detecting location...',
    },
    'ಕನ್ನಡ': {
      'profile': 'ಪ್ರೊಫೈಲ್',
      'edit': 'ತಿದ್ದುಪಡಿ',
      'farming_insights': 'ಕೃಷಿ ಒಳನೋಟಗಳು',
      'disease_scans': 'ರೋಗ ತಪಾಸಣೆ',
      'market_alerts': 'ಮಾರುಕಟ್ಟೆ ಎಚ್ಚರಿಕೆ',
      'community_posts': 'ಸಮುದಾಯ ಪೋಸ್ಟ್',
      'schemes_applied': 'ಯೋಜನೆಗಳು',
      'my_crops': 'ನನ್ನ ಬೆಳೆಗಳು',
      'location': 'ಸ್ಥಳ',
      'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'mandi_alerts': 'ಮಂಡಿ ದರ ಎಚ್ಚರಿಕೆ',
      'disease_alerts': 'ರೋಗ ಮುನ್ನೆಚ್ಚರಿಕೆ',
      'weather_updates': 'ಹವಾಮಾನ ಮಾಹಿತಿ',
      'app_settings': 'ಆ್ಯಪ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'language': 'ಭಾಷೆ',
      'admin_dashboard': 'ಅಡ್ಮಿನ್ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
      'help_support': 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'no_crops': 'ಇನ್ನೂ ಯಾವುದೇ ಬೆಳೆಗಳನ್ನು ಸೇರಿಸಲಾಗಿಲ್ಲ.',
      'humidity': 'ಆರ್ದ್ರತೆ',
      'detect_location': 'ಸ್ಥಳ ಪತ್ತೆಹಚ್ಚಲು ಸ್ಪರ್ಶಿಸಿ',
      'detecting': 'ಸ್ಥಳ ಪತ್ತೆಹಚ್ಚಲಾಗುತ್ತಿದೆ...',
    },
    'हिंदी': {
      'profile': 'प्रोफ़ाइल',
      'edit': 'संपादन',
      'farming_insights': 'कृषि अंतर्दृष्टि',
      'disease_scans': 'रोग स्कैन',
      'market_alerts': 'बाजार अलर्ट',
      'community_posts': 'सामुदायिक पोस्ट',
      'schemes_applied': 'लागू योजनाएं',
      'my_crops': 'मेरी फसलें',
      'location': 'स्थान',
      'notifications': 'सूचनाएं',
      'mandi_alerts': 'मंडी भाव अलर्ट',
      'disease_alerts': 'रोग चेतावनी अलर्ट',
      'weather_updates': 'मौसम अपडेट',
      'app_settings': 'ऐप सेटिंग्स',
      'language': 'भाषा',
      'admin_dashboard': 'एडमिन डैशबोर्ड',
      'help_support': 'सहायता और समर्थन',
      'logout': 'लॉग आउट',
      'no_crops': 'अभी तक कोई फसल नहीं जोड़ी गई।',
      'humidity': 'नमी',
      'detect_location': 'स्थान खोजने के लिए टैप करें',
      'detecting': 'स्थान खोजा जा रहा है...',
    }
  };

  String _t(String key) {
    return _translations[_language]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _autoUpdateLocation(); // Auto-update location on screen load
  }

  /// Silently fetches GPS location in the background and saves to profile
  Future<void> _autoUpdateLocation() async {
    final loc = await LocationService.getCurrentLocation();
    if (loc != null && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.updateProfile(loc);
      // Re-fetch profile to show updated location
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final profileData = await _apiService.getProfile();
      if (profileData['success'] == true) {
        // Backend sends data under 'data' OR 'user'
        final raw = profileData['data'] ?? profileData['user'];
        _user = UserModel.fromJson(raw);
        
        // Fetch weather if location is available
        if (_user?.location?.district != null) {
          try {
            _weather = await _weatherService.getWeather(_user!.location!.district!);
          } catch (e) {
            print('Weather fetch error: $e');
          }
        }
      }
    } catch (e) {
      print('Profile fetch error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_user != null) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
                              );
                              if (result == true) _fetchData();
                            }
                          },
                          child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
                    Text(_user?.name ?? 'Farmer', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_user?.phone ?? 'No Phone Number', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    
                    if (_weather != null) ...[
                      const SizedBox(height: 24),
                      _buildWeatherWidget(),
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
                    const Text('Farming Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    _buildInsightsGrid(),
                    
                    const SizedBox(height: 24),

                    // My Crops
                    const Text('My Crops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: _user?.farmDetails?.crops?.isNotEmpty == true
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: _user!.farmDetails!.crops!.map((crop) => _buildCropTag(crop, _getCropEmoji(crop))).toList(),
                            )
                          : const Text('No crops added yet.', style: TextStyle(color: Colors.grey)),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location
                    const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                                        Text('Detecting location...', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                                      ],
                                    )
                                  : Text(
                                      _user?.location?.district != null
                                          ? '${_user!.location!.district}, ${_user!.location!.state ?? ''}'
                                          : 'Tap to detect location',
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
                    const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _buildNotificationToggle('Mandi Price Alerts', _mandiAlerts, (val) => setState(() => _mandiAlerts = val)),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          _buildNotificationToggle('Disease Warning Alerts', _diseaseAlerts, (val) => setState(() => _diseaseAlerts = val)),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          _buildNotificationToggle('Weather Updates', _weatherAlerts, (val) => setState(() => _weatherAlerts = val)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // App Settings
                    const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.language, color: Colors.blue),
                            title: const Text('Language', style: TextStyle(fontSize: 16)),
                            trailing: Text(_language, style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                            onTap: _showLanguageDialog,
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                            title: const Text('Admin Dashboard', style: TextStyle(fontSize: 16)),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            onTap: () => Navigator.pushNamed(context, '/admin-notifications'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Help & Support
                    const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.help_outline, color: AppTheme.primaryGreen),
                            title: const Text('Help & Support', style: TextStyle(fontSize: 16, color: Colors.black87)),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            onTap: () => Navigator.pushNamed(context, '/help-support'),
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.red)),
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

  Widget _buildWeatherWidget() {
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Humidity', style: TextStyle(color: Colors.white70, fontSize: 10)),
              Text('72%', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Disease Scans', '12', Icons.bug_report_outlined, Colors.orange),
        _buildStatCard('Market Alerts', '48', Icons.trending_up, Colors.blue),
        _buildStatCard('Community Posts', '5', Icons.forum_outlined, Colors.purple),
        _buildStatCard('Schemes Applied', '2', Icons.assignment_outlined, Colors.green),
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                setState(() => _language = 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('ಕನ್ನಡ (Kannada)'),
              onTap: () {
                setState(() => _language = 'ಕನ್ನಡ');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('हिंदी (Hindi)'),
              onTap: () {
                setState(() => _language = 'हिंदी');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
