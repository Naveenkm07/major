import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class EditFarmDetailsScreen extends StatefulWidget {
  final UserModel user;

  const EditFarmDetailsScreen({super.key, required this.user});

  @override
  State<EditFarmDetailsScreen> createState() => _EditFarmDetailsScreenState();
}

class _EditFarmDetailsScreenState extends State<EditFarmDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _sizeCtrl;
  String? _selectedSoilType;
  String? _selectedIrrigation;
  
  List<String> _selectedCrops = [];
  
  final List<String> _availableCrops = [
    'Rice', 'Wheat', 'Maize', 'Sugarcane', 'Cotton', 'Tomato', 'Potato', 'Onion', 'Mango', 'Banana', 'Coffee', 'Tea', 'Arecanut', 'Coconut', 'Other'
  ];
  
  final List<String> _soilTypes = [
    'Red Soil', 'Black Soil', 'Alluvial Soil', 'Laterite Soil', 'Sandy Soil', 'Clay Soil', 'Other'
  ];
  
  final List<String> _irrigationTypes = [
    'Drip', 'Sprinkler', 'Rainfed', 'Canal', 'Tube Well', 'Other'
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sizeCtrl = TextEditingController(text: widget.user.farmDetails?.landArea?.toString() ?? '');
    _selectedSoilType = widget.user.farmDetails?.soilType;
    _selectedIrrigation = widget.user.farmDetails?.irrigationType;
    
    if (widget.user.farmDetails?.crops != null) {
      _selectedCrops = List.from(widget.user.farmDetails!.crops!);
    }
  }

  @override
  void dispose() {
    _sizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      final data = {
        'farmSize': double.tryParse(_sizeCtrl.text.trim()),
        'soilType': _selectedSoilType,
        'irrigationType': _selectedIrrigation,
        'cropTypes': _selectedCrops,
      };
      
      final success = await auth.updateProfile(data);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocale.t(context, 'profile_updated')), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(auth.error ?? 'Failed to update farm details'), backgroundColor: Colors.red),
          );
        }
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
        title: Text(AppLocale.t(context, 'edit_farm_details'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farm Size
                    Text('Farm Size (in Acres)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _sizeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5.5',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      validator: (val) {
                        if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Soil Type
                    Text('Soil Type', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSoilType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      hint: const Text('Select Soil Type'),
                      items: _soilTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) => setState(() => _selectedSoilType = val),
                    ),
                    const SizedBox(height: 24),
                    
                    // Irrigation Type
                    Text('Irrigation Method', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedIrrigation,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      hint: const Text('Select Irrigation Method'),
                      items: _irrigationTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) => setState(() => _selectedIrrigation = val),
                    ),
                    const SizedBox(height: 32),
                    
                    // My Crops
                    Text(AppLocale.t(context, 'my_crops'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: _availableCrops.map((crop) {
                        final isSelected = _selectedCrops.contains(crop);
                        return ChoiceChip(
                          label: Text(crop),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                          backgroundColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCrops.add(crop);
                              } else {
                                _selectedCrops.remove(crop);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(AppLocale.t(context, 'save'), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
