import 'package:flutter/material.dart';
import '../../config/theme.dart';
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
    _selectedCrops = List.from(widget.user.farmDetails?.crops ?? []);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updateData = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'farmDetails': {
        'landArea': double.tryParse(_landAreaCtrl.text),
        'soilType': _soilType,
        'irrigationType': _irrigationType,
        'crops': _selectedCrops,
      }
    };

    try {
      await _apiService.put('/auth/update-profile', updateData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
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
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
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
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _buildTextField('Full Name', _nameCtrl, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('Email Address', _emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Farm Details'),
              const SizedBox(height: 16),
              _buildTextField('Land Area (Acres)', _landAreaCtrl, Icons.landscape_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildDropdown('Soil Type', _soilType, _soilTypes, (val) => setState(() => _soilType = val)),
              const SizedBox(height: 16),
              _buildDropdown('Irrigation Type', _irrigationType, _irrigationTypes, (val) => setState(() => _irrigationType = val)),
              
              const SizedBox(height: 32),
              _buildSectionTitle('My Crops'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allCrops.map((crop) {
                  final isSelected = _selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(crop),
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
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      validator: (val) => val == null || val.isEmpty ? 'This field is required' : null,
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
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
