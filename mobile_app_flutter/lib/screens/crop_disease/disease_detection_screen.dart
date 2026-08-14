import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../data/disease_data.dart';
import '../../services/tflite_service.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final TFLiteService _tfliteService = TFLiteService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  
  List<Detection> _currentDetections = [];
  Map<String, dynamic>? _selectedResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeModelAndCamera();
  }

  Future<void> _initializeModelAndCamera() async {
    await _tfliteService.loadModel();
    if (mounted) {
      _setupCamera();
    }
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _isCameraInitialized = true);

      // Start streaming for real-time inference
      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || !_tfliteService.isLoaded) return;
        _isDetecting = true;

        _tfliteService.detect(image).then((detections) {
          if (mounted) {
            setState(() {
              _currentDetections = detections;
              // If high confidence detection is found, auto-trigger result sheet
              if (detections.isNotEmpty && detections.first.confidence > 0.6 && _selectedResult == null) {
                _showResult(detections.first);
              }
            });
          }
          _isDetecting = false;
        }).catchError((e) {
          _isDetecting = false;
        });
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  Future<void> _pickGalleryImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
      if (picked != null) {
        setState(() => _isDetecting = true);
        _cameraController?.stopImageStream();
        
        final detections = await _tfliteService.detectFromFile(picked.path);
        
        setState(() {
          _isDetecting = false;
          _currentDetections = detections;
          if (detections.isNotEmpty) {
            _showResult(detections.first);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No disease detected in the image.')),
            );
            _setupCamera(); // Resume camera if nothing found
          }
        });
      }
    } catch (e) {
      setState(() => _isDetecting = false);
      print('Gallery error: $e');
    }
  }

  void _showResult(Detection detection) {
    if (_selectedResult != null) return; // Prevent multiple sheets
    
    final dbEntry = DiseaseData.diseaseDb[detection.label] ?? DiseaseData.diseaseDb['healthy']!;
    
    setState(() {
      _selectedResult = {
        'pest': detection.label,
        'confidence': detection.confidence,
        'description': dbEntry['description'],
        'treatment': dbEntry['treatment'],
      };
    });
    
    // Pause stream while showing sheet
    _cameraController?.stopImageStream();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _buildBottomSheet(),
    ).then((_) {
      if (mounted) {
        setState(() => _selectedResult = null);
        _setupCamera(); // Resume
      }
    });
  }

  Widget _buildBottomSheet() {
    final pest = _selectedResult?['pest']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN';
    final confidence = _selectedResult?['confidence'] as double? ?? 0.0;
    final description = _selectedResult?['description']?.toString() ?? '';
    final treatmentList = _selectedResult?['treatment'] as List<String>? ?? [];
    final treatment = treatmentList.isNotEmpty ? '• ${treatmentList.join('\n• ')}' : 'No treatment info.';
    final isHighSeverity = confidence > 0.7 && pest != 'HEALTHY';
    
    final locale = Provider.of<AppLocale>(context, listen: false);

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
              Text('${locale.get('diagnosis_result') ?? 'Diagnosis result'} (${(confidence * 100).toStringAsFixed(1)}% match)', 
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              if (isHighSeverity)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.pestRed, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(locale.get('high_severity') ?? 'High Severity', 
                           style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                Text(locale.get('recommended_treatment') ?? 'Recommended Treatment', 
                     style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Discard', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ask AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final size = MediaQuery.of(context).size;
    final locale = Provider.of<AppLocale>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            SizedBox(
              width: size.width,
              height: size.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? size.width,
                  height: _cameraController!.value.previewSize?.width ?? size.height,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
          
          // Bounding Box Overlays
          if (_currentDetections.isNotEmpty && _selectedResult == null)
            CustomPaint(
              size: size,
              painter: BoundingBoxPainter(_currentDetections, size),
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
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.center_focus_weak, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _tfliteService.isLoaded ? 'Model Ready' : 'Loading Model...',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Actions
          if (_selectedResult == null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickGalleryImage,
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: Text(locale.get('gallery') ?? 'Gallery', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black.withOpacity(0.6),
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

class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final Size screenSize;

  BoundingBoxPainter(this.detections, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final bgPaint = Paint()
      ..color = AppTheme.primaryGreen.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (var detection in detections) {
      // Map bounding box to screen coordinates
      // Note: This relies on the camera preview filling the screen.
      final rect = detection.boundingBox;
      
      canvas.drawRect(rect, paint);

      // Draw label text background
      final textSpan = TextSpan(
        text: '${detection.label} ${(detection.confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        rect.left,
        rect.top - 24,
        textPainter.width + 12,
        24,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(labelRect, const Radius.circular(4)), bgPaint);
      
      textPainter.paint(canvas, Offset(rect.left + 6, rect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
