import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  
  File? _newAvatarFile;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  final List<String> _allCrops = ['Tomato', 'Ragi', 'Onion', 'Coconut', 'Paddy', 'Maize', 'Sugarcane', 'Cotton'];
  final List<String> _soilTypes = ['Red Soil', 'Black Soil', 'Alluvial Soil', 'Laterite Soil'];
  final List<String> _irrigationTypes = ['Drip', 'Sprinkler', 'Borewell', 'Rain-fed'];

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.user.avatar;
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _landAreaCtrl = TextEditingController(text: widget.user.farmDetails?.landArea?.toString() ?? '');
    _soilType = widget.user.farmDetails?.soilType;
    _irrigationType = widget.user.farmDetails?.irrigationType;
    _selectedCrops = widget.user.farmDetails?.crops?.map((c) => c.name).toList() ?? [];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _newAvatarFile = File(image.path);
      });
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    // ⚠️ Replace with your actual Cloudinary Cloud Name and Upload Preset
    const String cloudName = 'dqeud7ply'; 
    const String uploadPreset = 'krushika';
    
    if (cloudName.contains('YOUR_CLOUD')) {
      // Return a dummy if they didn't replace it to prevent crashing
      return 'https://ui-avatars.com/api/?name=${_nameCtrl.text.trim().replaceAll(' ', '+')}';
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      return json['secure_url'];
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? finalAvatarUrl = _avatarUrl;
    if (_newAvatarFile != null) {
      final uploadedUrl = await _uploadToCloudinary(_newAvatarFile!);
      if (uploadedUrl != null) {
        finalAvatarUrl = uploadedUrl;
      }
    }

    final updateData = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'farmSize': double.tryParse(_landAreaCtrl.text),
      'soilType': _soilType,
      'irrigationType': _irrigationType,
      'cropTypes': _selectedCrops,
      if (finalAvatarUrl != null) 'avatar': finalAvatarUrl,
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
              Center(
                child: Stack(
                  children: [
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(50),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        backgroundImage: _newAvatarFile != null 
                            ? FileImage(_newAvatarFile!) as ImageProvider
                            : (_avatarUrl != null ? CachedNetworkImageProvider(_avatarUrl!) : null),
                        child: (_newAvatarFile == null && _avatarUrl == null)
                            ? const Icon(Icons.person, size: 50, color: AppTheme.primaryGreen)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
