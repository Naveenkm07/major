import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/pest_scan_model.dart';

class DiseaseScanHistoryScreen extends StatefulWidget {
  const DiseaseScanHistoryScreen({super.key});

  @override
  State<DiseaseScanHistoryScreen> createState() => _DiseaseScanHistoryScreenState();
}

class _DiseaseScanHistoryScreenState extends State<DiseaseScanHistoryScreen> {
  final _api = ApiService();
  List<PestScanModel> _scans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await _api.getScanHistory(limit: 50);
      if (res['success'] == true) {
        final List data = res['data'] ?? [];
        setState(() {
          _scans = data.map((json) => PestScanModel.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching scan history: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Disease Scans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _scans.isEmpty
              ? const Center(
                  child: Text(
                    'No scan history found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scans.length,
                  itemBuilder: (context, index) {
                    final scan = _scans[index];
                    return _ScanCard(scan: scan);
                  },
                ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final PestScanModel scan;

  const _ScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          if (scan.imageUrl.isNotEmpty)
            Image.network(
              scan.imageUrl,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        scan.cropType,
                        style: const TextStyle(
                          color: AppTheme.accentDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${scan.scanDate.day}/${scan.scanDate.month}/${scan.scanDate.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  scan.diseaseDetected,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (scan.treatmentSuggestion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    scan.treatmentSuggestion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
