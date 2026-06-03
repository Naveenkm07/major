import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';
import '../../models/equipment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedType = 'All';
  final List<String> _types = ['All', 'Tractor', 'Harvester', 'Plough', 'Seeder', 'Sprayer'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<EquipmentProvider>(context, listen: false).fetchEquipment());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'equipment_rental')),
        actions: const [LanguageToggle(), SizedBox(width: 10)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEquipmentBottomSheet(context),
        label: Text(AppLocale.t(context, 'list_equipment')),
        icon: const Icon(Icons.add_business_rounded),
      ),
      body: Column(
        children: [
          // ─── Filters ──────────────────────────
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final type = _types[index];
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(AppLocale.t(context, type.toLowerCase())),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedType = type);
                      Provider.of<EquipmentProvider>(context, listen: false).fetchEquipment(type: type);
                    },
                    selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                  ),
                );
              },
            ),
          ),

          // ─── Grid ─────────────────────────────
          Expanded(
            child: Consumer<EquipmentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (provider.equipment.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.agriculture_rounded, size: 64, color: AppTheme.textHint),
                        const SizedBox(height: 16),
                        Text(AppLocale.t(context, 'no_equipment_found')),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: provider.equipment.length,
                  itemBuilder: (context, index) => _EquipmentCard(item: provider.equipment[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEquipmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const _AddEquipmentForm(),
    );
  }
}

class _AddEquipmentForm extends StatefulWidget {
  const _AddEquipmentForm();

  @override
  State<_AddEquipmentForm> createState() => _AddEquipmentFormState();
}

class _AddEquipmentFormState extends State<_AddEquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Tractor';
  String _price = '';
  String _phone = '';
  String _desc = '';
  bool _isLoading = false;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  final List<String> _types = ['Tractor', 'Harvester', 'Plough', 'Seeder', 'Sprayer', 'Other'];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 70);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.phone != null) {
      _phone = user.phone!;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;
    final data = {
      'name': _name,
      'type': _type,
      'pricePerHour': double.tryParse(_price) ?? 0,
      'contactPhone': _phone,
      'description': _desc,
      'owner': user?.id ?? 'unknown_uid',
      'ownerName': user?.userMetadata?['full_name'] ?? 'Farmer',
      'availability': true,
      if (_base64Image != null) 'images': [_base64Image],
    };

    final success = await Provider.of<EquipmentProvider>(context, listen: false).addEquipment(data);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipment added successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add equipment.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocale.t(context, 'list_new_equipment'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(labelText: AppLocale.t(context, 'equipment_name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(labelText: AppLocale.t(context, 'type'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(AppLocale.t(context, t.toLowerCase())))).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: AppLocale.t(context, 'price_per_hour'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _price = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _phone,
                decoration: InputDecoration(labelText: AppLocale.t(context, 'contact_phone'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _phone = v!,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (c) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: Text(AppLocale.t(context, 'pick_from_gallery')),
                            onTap: () { Navigator.pop(c); _pickImage(ImageSource.gallery); },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: Text(AppLocale.t(context, 'take_a_photo')),
                            onTap: () { Navigator.pop(c); _pickImage(ImageSource.camera); },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.05),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _base64Image != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(_base64Image!.split(',').last),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryGreen, size: 36),
                          const SizedBox(height: 8),
                          Text(AppLocale.t(context, 'add_equipment_photo'), style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: AppLocale.t(context, 'description_optional'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                maxLines: 2,
                onSaved: (v) => _desc = v ?? '',
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocale.t(context, 'list_equipment'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final EquipmentModel item;
  const _EquipmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: item.images.isNotEmpty && item.images.first.startsWith('data:image')
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.memory(
                        base64Decode(item.images.first.split(',').last),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Icon(
                        item.type == 'Tractor' ? Icons.agriculture_rounded : Icons.precision_manufacturing_rounded,
                        size: 48,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1)),
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        final isBookmarked = auth.user?.savedEquipment.contains(item.id) ?? false;
                        return GestureDetector(
                          onTap: () => auth.toggleEquipmentBookmark(item.id),
                          child: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                            color: isBookmarked ? AppTheme.primaryGreen : Colors.grey,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('₹${item.pricePerHour}/hr', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item.district ?? 'Unknown', style: const TextStyle(fontSize: 10, color: AppTheme.textHint), maxLines: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocale.t(context, 'rent_now'), style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
