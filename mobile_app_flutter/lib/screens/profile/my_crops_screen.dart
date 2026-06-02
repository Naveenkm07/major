import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class MyCropsScreen extends StatefulWidget {
  final List<CropEntryModel> currentCrops;
  const MyCropsScreen({super.key, required this.currentCrops});

  @override
  State<MyCropsScreen> createState() => _MyCropsScreenState();
}

class _MyCropsScreenState extends State<MyCropsScreen> {
  final _apiService = ApiService();
  late List<CropEntryModel> _crops;
  bool _isSaving = false;

  final List<String> _availableCrops = [
    'Rice', 'Paddy', 'Wheat', 'Maize', 'Tomato', 'Onion', 
    'Sugarcane', 'Cotton', 'Ragi', 'Coconut', 'Coffee', 'Turmeric'
  ];

  @override
  void initState() {
    super.initState();
    _crops = List.from(widget.currentCrops);
  }

  void _addCrop(String name) {
    if (_crops.any((c) => c.name.toLowerCase() == name.toLowerCase())) return;
    setState(() {
      _crops.add(CropEntryModel(name: name, sowingDate: DateTime.now()));
    });
  }

  void _removeCrop(int index) {
    setState(() {
      _crops.removeAt(index);
    });
  }

  Future<void> _selectDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _crops[index].sowingDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _crops[index] = CropEntryModel(name: _crops[index].name, sowingDate: picked);
      });
    }
  }

  Future<void> _saveCrops() async {
    setState(() => _isSaving = true);
    try {
      // Prepare data for backend
      // We map to the structure expected by /auth/update-profile
      final cropData = _crops.map((c) => {
        'name': c.name,
        'sowingDate': c.sowingDate?.toIso8601String(),
      }).toList();

      await _apiService.put('/auth/update-profile', {
        'farmDetails': {'crops': cropData}
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.t(context, 'profile_updated'))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'my_crops'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ─── Add Crop Section ────────────────
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select a crop to add:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableCrops.map((crop) {
                      final isAdded = _crops.any((c) => c.name == crop);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(crop),
                          onPressed: isAdded ? null : () => _addCrop(crop),
                          backgroundColor: isAdded ? Colors.grey.shade100 : Colors.white,
                          side: BorderSide(color: isAdded ? Colors.grey.shade300 : AppTheme.primaryGreen),
                          labelStyle: TextStyle(color: isAdded ? Colors.grey : AppTheme.primaryGreen),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ─── List of Added Crops ─────────────
          Expanded(
            child: _crops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(AppLocale.t(context, 'no_crops'), style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _crops.length,
                    itemBuilder: (context, index) {
                      final crop = _crops[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.eco, color: AppTheme.primaryGreen),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _selectDate(index),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Text(
                                          crop.sowingDate != null 
                                            ? 'Sown on: ${DateFormat('MMM dd, yyyy').format(crop.sowingDate!)}'
                                            : 'Set sowing date',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _removeCrop(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ─── Save Button ─────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveCrops,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(AppLocale.t(context, 'save_changes'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
