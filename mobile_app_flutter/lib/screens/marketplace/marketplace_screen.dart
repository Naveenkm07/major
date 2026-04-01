import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';
import '../../models/equipment_model.dart';

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
        onPressed: () => _showAddEquipmentDialog(context),
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
                    label: Text(type),
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

  void _showAddEquipmentDialog(BuildContext context) {
    // Simplified add dialog for demo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocale.t(context, 'feature_coming_soon'))),
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
              child: Center(
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
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
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
