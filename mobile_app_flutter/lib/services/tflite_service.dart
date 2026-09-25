import 'dart:async';
import 'package:camera/camera.dart';

class ClassificationResult {
  final String label;
  final int classIndex;
  final double confidence;

  ClassificationResult(this.label, this.classIndex, this.confidence);
}

class TFLiteService {
  bool _isLoaded = false;
  
  bool get isLoaded => _isLoaded;
  bool get hasValidMetadata => true;

  Future<void> loadModel() async {
    // Mock loading model
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoaded = true;
    print('Mock TFLite classifier loaded successfully');
  }

  void dispose() {
    _isLoaded = false;
  }

  Future<ClassificationResult?> detectFromFile(String imagePath) async {
    if (!isLoaded) return null;
    await Future.delayed(const Duration(milliseconds: 800));
    // Return a mock result
    return ClassificationResult("Apple___healthy", 0, 0.95);
  }

  Future<ClassificationResult?> detect(CameraImage cameraImage) async {
    if (!isLoaded) return null;
    await Future.delayed(const Duration(milliseconds: 300));
    // Return a mock result
    return ClassificationResult("Tomato___healthy", 1, 0.98);
  }
}
