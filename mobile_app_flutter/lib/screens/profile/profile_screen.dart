import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _cropTypesController = TextEditingController();
  String _preferredLanguage = 'kn';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user != null) {
      _nameController.text = user.name;
      _villageController.text = user.location?.village ?? '';
      _districtController.text = user.location?.district ?? '';
      _stateController.text = user.location?.state ?? '';
      _farmSizeController.text = user.farmDetails?.landArea?.toString() ?? '';
      _cropTypesController.text = user.farmDetails?.crops?.join(', ') ?? '';
      _preferredLanguage = user.preferredLanguage ?? 'kn';
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final crops = _cropTypesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      final data = {
        'name': _nameController.text.trim(),
        'village': _villageController.text.trim(),
        'district': _districtController.text.trim(),
        'state': _stateController.text.trim(),
        'farmSize': double.tryParse(_farmSizeController.text.trim()),
        'cropTypes': crops,
        'preferredLanguage': _preferredLanguage,
      };

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.updateProfile(data);

      if (success) {
        setState(() => _isEditing = false);
        if (mounted) {
          final locale = Provider.of<AppLocale>(context, listen: false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(locale.tr('profile_updated'))));
          locale.setLanguage(_preferredLanguage);
        }
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppLocale>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.tr('profile')),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _loadUserData(); // reset
                setState(() => _isEditing = false);
              },
            )
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ─── Avatar ──────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.surface,
                    child: Icon(Icons.person_rounded, size: 48, color: AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(height: 16),
                
                if (!_isEditing) ...[
                  Text(user?.name ?? 'Farmer', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(user?.phone ?? '', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),

                  _InfoCard(
                    icon: Icons.language_rounded,
                    label: locale.tr('preferred_language'),
                    value: _preferredLanguage == 'kn' ? 'ಕನ್ನಡ (Kannada)' : _preferredLanguage == 'hi' ? 'हिंदी (Hindi)' : 'English',
                  ),
                  _InfoCard(
                    icon: Icons.location_on_rounded,
                    label: locale.tr('location'),
                    value: user?.location != null
                        ? '${user!.location!.village ?? ''}, ${user.location!.district ?? ''}, ${user.location!.state ?? ''}'
                        : locale.tr('not_set'),
                  ),
                  _InfoCard(
                    icon: Icons.landscape_rounded,
                    label: locale.tr('land_area'),
                    value: user?.farmDetails?.landArea != null ? '${user!.farmDetails!.landArea}' : locale.tr('not_set'),
                  ),
                  _InfoCard(
                    icon: Icons.eco_rounded,
                    label: locale.tr('crops_grown'),
                    value: user?.farmDetails?.crops?.join(', ') ?? locale.tr('not_set'),
                  ),
                ] else ...[
                  _buildTextField(locale.tr('full_name'), _nameController, Icons.person_outline),
                  _buildTextField(locale.tr('village'), _villageController, Icons.location_city),
                  _buildTextField(locale.tr('district'), _districtController, Icons.map_outlined),
                  _buildTextField(locale.tr('state'), _stateController, Icons.map),
                  _buildTextField(locale.tr('land_area'), _farmSizeController, Icons.landscape, keyboardType: TextInputType.number),
                  _buildTextField(locale.tr('crop_types_hint'), _cropTypesController, Icons.eco_outlined),
                  
                  // Language Dropdown
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _preferredLanguage,
                        isExpanded: true,
                        icon: const Icon(Icons.language_rounded),
                        items: const [
                          DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ (Kannada)')),
                          DropdownMenuItem(value: 'hi', child: Text('हिंदी (Hindi)')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _preferredLanguage = val);
                        },
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(locale.tr('save_profile'), style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ─── Logout ──────────────────────
                if (!_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        auth.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                      label: Text(locale.tr('logout'), style: const TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: AppTheme.surface,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
