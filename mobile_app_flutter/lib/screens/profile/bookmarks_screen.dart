import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _api = ApiService();

  List<dynamic> _schemes = [];
  List<dynamic> _equipment = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all schemes and equipment
      final schemesRes = await _api.getSchemes();
      final equipRes = await _api.getEquipment();

      if (schemesRes['success'] == true) {
        _schemes = schemesRes['data'] ?? [];
      }
      if (equipRes['success'] == true) {
        _equipment = equipRes['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching bookmarks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Filter items based on user's saved IDs
    final savedSchemesIds = user?.savedSchemes ?? [];
    final savedEquipmentIds = user?.savedEquipment ?? [];

    final displaySchemes = _schemes.where((s) => savedSchemesIds.contains(s['_id'] ?? s['id'])).toList();
    final displayEquipment = _equipment.where((e) => savedEquipmentIds.contains(e['_id'] ?? e['id'])).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Saved Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Schemes'),
            Tab(text: 'Equipment'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSchemesList(displaySchemes, auth),
                _buildEquipmentList(displayEquipment, auth),
              ],
            ),
    );
  }

  Widget _buildSchemesList(List<dynamic> schemes, AuthProvider auth) {
    if (schemes.isEmpty) {
      return const Center(child: Text('No saved schemes yet.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schemes.length,
      itemBuilder: (context, index) {
        final scheme = schemes[index];
        final id = scheme['_id'] ?? scheme['id'];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(scheme['title'] ?? 'Unknown Scheme', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                scheme['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark, color: AppTheme.primaryGreen),
              onPressed: () => auth.toggleSchemeBookmark(id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEquipmentList(List<dynamic> equipment, AuthProvider auth) {
    if (equipment.isEmpty) {
      return const Center(child: Text('No saved equipment yet.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: equipment.length,
      itemBuilder: (context, index) {
        final item = equipment[index];
        final id = item['_id'] ?? item['id'];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: item['images'] != null && (item['images'] as List).isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['images'][0],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  )
                : const Icon(Icons.agriculture, size: 40, color: Colors.grey),
            title: Text(item['title'] ?? item['name'] ?? 'Equipment', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('₹${item['price'] ?? item['rentalPricePerDay'] ?? 0}'),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark, color: AppTheme.primaryGreen),
              onPressed: () => auth.toggleEquipmentBookmark(id),
            ),
          ),
        );
      },
    );
  }
}
