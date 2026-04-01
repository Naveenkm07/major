import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

/// Pest Detection Screen
/// ┌────────────────────────────────────────┐
/// │ AppBar: "Pest Detection"               │
/// │ ┌──────────────────────────────────┐   │
/// │ │  Image Preview / Placeholder     │   │
/// │ └──────────────────────────────────┘   │
/// │ [ 📷 Camera ]  [ 🖼 Gallery ]          │
/// │ [=== Detect Disease (Button) ===]      │
/// │ ┌──────────────────────────────────┐   │
/// │ │  Result Card:                    │   │
/// │ │  ● Disease name + confidence     │   │
/// │ │  ● Description                   │   │
/// │ │  ● Treatment list                │   │
/// │ │  ● Prevention list               │   │
/// │ └──────────────────────────────────┘   │
/// └────────────────────────────────────────┘
class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final _api = ApiService();
  final _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  // ─── Camera / Gallery Capture ────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _result = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to capture image: $e');
    }
  }

  // ─── Send to AI Service ─────────────────────────
  Future<void> _detectDisease() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.detectPest(_imageFile!);
      setState(() => _result = data);
    } catch (e) {
      setState(() => _error = 'Detection failed. Check your connection.');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'pest_scan')),
        actions: const [LanguageToggle(), SizedBox(width: 10)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Info Banner ────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocale.t(context, 'capture_photo'),
                      style: TextStyle(fontSize: 13, color: AppTheme.info, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Image Preview ─────────────────────
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
                image: _imageFile != null
                    ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                    : null,
              ),
              child: _imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, size: 56, color: AppTheme.textHint),
                        const SizedBox(height: 12),
                        Text(AppLocale.t(context, 'capture_photo'), style: TextStyle(color: AppTheme.textHint, fontSize: 14), textAlign: TextAlign.center),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // ─── Camera / Gallery Buttons ──────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(AppLocale.t(context, 'camera')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(AppLocale.t(context, 'gallery')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Detect Button ────────────────────
            ElevatedButton.icon(
              onPressed: _imageFile != null && !_isLoading ? _detectDisease : null,
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search_rounded),
              label: Text(_isLoading ? AppLocale.t(context, 'analyzing') : AppLocale.t(context, 'detect_disease')),
            ),

            // ─── Error ────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                  ],
                ),
              ),
            ],

            // ─── Result Card ──────────────────────
            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget tree for the detection result display
/// ┌─ Card ──────────────────────────────────┐
/// │ ┌─ Row ───────────────────────────────┐ │
/// │ │ 🔴 Disease Name    95.2% confidence │ │
/// │ └─────────────────────────────────────┘ │
/// │ Description text...                     │
/// │ ─── Treatment ────────────────────────  │
/// │ • Spray Propiconazole 25EC...           │
/// │ ─── Prevention ───────────────────────  │
/// │ • Plant rust-resistant varieties...     │
/// └────────────────────────────────────────┘
class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final pest = result['pest'] ?? 'Unknown';
    final confidence = (result['confidence'] ?? 0).toDouble();
    final isHealthy = pest.toLowerCase() == 'healthy';
    final headerColor = isHealthy ? AppTheme.success : AppTheme.error;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: headerColor.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(isHealthy ? Icons.check_circle : Icons.warning_rounded, color: headerColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pest.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: headerColor),
                      ),
                      Text('${(confidence * 100).toStringAsFixed(1)}% ${AppLocale.t(context, 'confidence')}', style: TextStyle(fontSize: 13, color: headerColor.withOpacity(0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result['description'] != null) ...[
                  Text(result['description'], style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                ],

                // Treatment section
                if (result['treatment'] != null && (result['treatment'] as List).isNotEmpty) ...[
                  _SectionHeader(icon: Icons.medical_services_rounded, title: AppLocale.t(context, 'treatment'), color: AppTheme.pestRed),
                  const SizedBox(height: 8),
                  ...(result['treatment'] as List).map((t) => _BulletPoint(text: t.toString(), color: AppTheme.pestRed)),
                  const SizedBox(height: 14),
                ],

                // Prevention section
                if (result['prevention'] != null && (result['prevention'] as List).isNotEmpty) ...[
                  _SectionHeader(icon: Icons.shield_rounded, title: AppLocale.t(context, 'prevention'), color: AppTheme.info),
                  const SizedBox(height: 8),
                  ...(result['prevention'] as List).map((p) => _BulletPoint(text: p.toString(), color: AppTheme.info)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: color)),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletPoint({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6, height: 6,
            decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}
