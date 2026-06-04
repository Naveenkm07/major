import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _result = null;
        });
        _detectDisease();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open camera/gallery. Please check permissions. Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _detectDisease() async {
    if (_imageFile == null) return;
    setState(() => _isLoading = true);
    
    // UI Simulation delay to show the scanning animation (simulating TFLite inference time)
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Offline Simulated TFLite Prediction
      // In a real app with the .tflite model, we would use tflite_flutter here.
      final mockData = {
        'success': true,
        'data': {
          'pest': 'leaf_blight',
          'confidence': 0.89,
          'description': 'Leaf blight appears as dry, brown spots on the leaves. It spreads quickly in humid conditions.',
          'treatment': [
            'Remove affected leaves immediately.',
            'Spray copper-based fungicide.',
            'Ensure proper plant spacing for air circulation.'
          ]
        }
      };

      setState(() => _result = mockData);
      _showResultBottomSheet();
    } catch (e) {
      setState(() => _isLoading = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    final pest = _result?['data']?['pest']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN DISEASE';
    final confidence = _result?['data']?['confidence'] as double? ?? 0.0;
    final description = _result?['data']?['description']?.toString() ?? 'No description available.';
    final treatmentList = _result?['data']?['treatment'] as List<dynamic>? ?? [];
    final treatment = treatmentList.isNotEmpty ? '• ${treatmentList.join('\n• ')}' : 'No treatment info.';
    final isHighSeverity = confidence > 0.7;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diagnosis result (${(confidence * 100).toStringAsFixed(1)}% match)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              if (isHighSeverity)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.pestRed, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('High Severity', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(pest, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
          ),
          
          const SizedBox(height: 20),
          
          // Treatment Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recommended Treatment', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  treatment,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved to My Disease Scans in Profile!'),
                        backgroundColor: AppTheme.primaryGreen,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save to Profile', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close sheet
                    // Ask the chatbot
                    final chatMsg = 'How do I organically treat $pest?';
                    // We can just push the chatbot screen, the user can type it. Or we can inject it via provider if imported, but to keep it simple:
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ask AI: Organic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3B2F), // Dark greenish background for scanner
      body: Stack(
        children: [
          // Background Image (Live Camera Feed simulation)
          if (_imageFile != null)
            Positioned.fill(
              child: kIsWeb 
                  ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                  : Image.file(_imageFile!, fit: BoxFit.cover),
            )
          else
            Positioned.fill(
              child: Center(
                child: Icon(Icons.eco_rounded, size: 300, color: AppTheme.primaryGreen.withOpacity(0.4)),
              ),
            ),
          
          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // Scanner UI overlay
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Scanning leaf...', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.accentDark, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Detected', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 20),
                // Orange brackets graphic
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      // Top Left
                      Positioned(top: 0, left: 0, child: Container(width: 40, height: 4, color: AppTheme.accent)),
                      Positioned(top: 0, left: 0, child: Container(width: 4, height: 40, color: AppTheme.accent)),
                      // Top Right
                      Positioned(top: 0, right: 0, child: Container(width: 40, height: 4, color: AppTheme.accent)),
                      Positioned(top: 0, right: 0, child: Container(width: 4, height: 40, color: AppTheme.accent)),
                      // Bottom Left
                      Positioned(bottom: 0, left: 0, child: Container(width: 40, height: 4, color: AppTheme.accent)),
                      Positioned(bottom: 0, left: 0, child: Container(width: 4, height: 40, color: AppTheme.accent)),
                      // Bottom Right
                      Positioned(bottom: 0, right: 0, child: Container(width: 40, height: 4, color: AppTheme.accent)),
                      Positioned(bottom: 0, right: 0, child: Container(width: 4, height: 40, color: AppTheme.accent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Demo Buttons
          if (!_isLoading && _result == null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: const Text('Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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
