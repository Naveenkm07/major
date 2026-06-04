import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _landAreaCtrl;
  String? _soilType;
  String? _irrigationType;
  List<String> _selectedCrops = [];
  bool _isLoading = false;

  final List<String> _allCrops = ['Tomato', 'Ragi', 'Onion', 'Coconut', 'Paddy', 'Maize', 'Sugarcane', 'Cotton'];
  final List<String> _soilTypes = ['Red Soil', 'Black Soil', 'Alluvial Soil', 'Laterite Soil'];
  final List<String> _irrigationTypes = ['Drip', 'Sprinkler', 'Borewell', 'Rain-fed'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _landAreaCtrl = TextEditingController(text: widget.user.farmDetails?.landArea?.toString() ?? '');
    _soilType = widget.user.farmDetails?.soilType;
    _irrigationType = widget.user.farmDetails?.irrigationType;
    _selectedCrops = widget.user.farmDetails?.crops?.map((c) => c.name).toList() ?? [];
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updateData = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'farmSize': double.tryParse(_landAreaCtrl.text),
      'soilType': _soilType,
      'irrigationType': _irrigationType,
      'cropTypes': _selectedCrops,
    };

    try {
      await _apiService.put('/auth/update-profile', updateData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.t(context, 'profile_updated'))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'edit'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(AppLocale.t(context, 'basic_info')),
              const SizedBox(height: 16),
              _buildTextField(AppLocale.t(context, 'full_name'), _nameCtrl, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(AppLocale.t(context, 'email'), _emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              
              const SizedBox(height: 32),
              _buildSectionTitle(AppLocale.t(context, 'farm_details_title')),
              const SizedBox(height: 16),
              _buildTextField(AppLocale.t(context, 'land_area'), _landAreaCtrl, Icons.landscape_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildDropdown(AppLocale.t(context, 'soil_type'), _soilType, _soilTypes, (val) => setState(() => _soilType = val)),
              const SizedBox(height: 16),
              _buildDropdown(AppLocale.t(context, 'irrigation_type'), _irrigationType, _irrigationTypes, (val) => setState(() => _irrigationType = val)),
              
              const SizedBox(height: 32),
              _buildSectionTitle(AppLocale.t(context, 'my_crops')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allCrops.map((crop) {
                  final isSelected = _selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(AppLocale.t(context, crop)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCrops.add(crop);
                        } else {
                          _selectedCrops.remove(crop);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryGreen : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 48),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocale.t(context, 'save_changes'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (val) => val == null || val.isEmpty ? AppLocale.t(context, 'required') : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.info_outline, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(AppLocale.t(context, e)))).toList(),
      onChanged: onChanged,
    );
  }
}
