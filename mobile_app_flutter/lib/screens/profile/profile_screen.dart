import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/weather_service.dart';
import '../../models/user_model.dart';
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
  
  bool _mandiAlerts = true;
  bool _diseaseAlerts = true;
  bool _weatherAlerts = false;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final profileData = await _apiService.getProfile();
      if (profileData['success'] == true) {
        _user = UserModel.fromJson(profileData['user']);
        
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppTheme.accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _user?.location?.district != null 
                                  ? '${_user!.location!.district}, ${_user!.location!.state}'
                                  : 'Location not set', 
                              style: const TextStyle(fontSize: 16)
                            )
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
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
