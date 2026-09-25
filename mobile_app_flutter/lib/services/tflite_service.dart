import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassificationResult {
  final String label;
  final int classIndex;
  final double confidence;

  ClassificationResult(this.label, this.classIndex, this.confidence);
}

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isLoaded = false;
  
  bool get isLoaded => _isLoaded;
  bool get hasValidMetadata => _interpreter != null;

  static const int _inputSize = 224;

  Future<void> loadModel() async {
    try {
      // 1. Load Interpreter
      final options = InterpreterOptions();
      // Use XNNPACK for CPU acceleration
      if (Platform.isAndroid) options.addDelegate(XNNPackDelegate());
      
      _interpreter = await Interpreter.fromAsset('assets/models/plant_disease_model.tflite', options: options);
      
      // 2. Load Labels
      final labelData = await rootBundle.loadString('assets/models/disease_labels.txt');
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();
      
      _isLoaded = true;
      print('Real TFLite model loaded successfully! CPU Accelerated.');
    } catch (e) {
      print('Failed to load TFLite model: $e');
      _isLoaded = false;
    }
  }

  void dispose() {
    _interpreter?.close();
    _isLoaded = false;
  }

  Future<ClassificationResult?> detectFromFile(String imagePath) async {
    if (!isLoaded || _interpreter == null) return null;
    
    try {
      final imageBytes = File(imagePath).readAsBytesSync();
      var image = img.decodeImage(imageBytes);
      if (image == null) return null;
      
      return _runInference(image);
    } catch (e) {
      print("File detection error: $e");
      return null;
    }
  }

  Future<ClassificationResult?> detect(CameraImage cameraImage) async {
    if (!isLoaded || _interpreter == null) return null;
    
    try {
      var image = _convertCameraImage(cameraImage);
      if (image == null) return null;
      
      return _runInference(image);
    } catch (e) {
      print("Camera detection error: $e");
      return null;
    }
  }

  ClassificationResult? _runInference(img.Image originalImage) {
    // 1. Resize image to 224x224
    var image = img.copyResize(originalImage, width: _inputSize, height: _inputSize);
    
    // 2. Normalize and convert to float32 input [1, 224, 224, 3] or uint8 depending on model
    // Our Python script uses tf.lite.Optimize.DEFAULT, so it likely expects float32 if we didn't provide representative dataset
    // Or int8. We will check the tensor type.
    final inputTensor = _interpreter!.getInputTensor(0);
    final isQuantized = inputTensor.type == TensorType.uint8 || inputTensor.type == TensorType.int8;
    
    var inputBuffer = Float32List(_inputSize * _inputSize * 3);
    var intBuffer = Uint8List(_inputSize * _inputSize * 3);
    
    int pixelIndex = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        if (isQuantized) {
          intBuffer[pixelIndex++] = pixel.r.toInt();
          intBuffer[pixelIndex++] = pixel.g.toInt();
          intBuffer[pixelIndex++] = pixel.b.toInt();
        } else {
          // Normalizing for MobileNetV3 (ImageNet) -> [-1, 1] or [0, 1]
          inputBuffer[pixelIndex++] = (pixel.r.toInt() / 127.5) - 1.0;
          inputBuffer[pixelIndex++] = (pixel.g.toInt() / 127.5) - 1.0;
          inputBuffer[pixelIndex++] = (pixel.b.toInt() / 127.5) - 1.0;
        }
      }
    }
    
    final inputObj = isQuantized 
        ? intBuffer.reshape([1, _inputSize, _inputSize, 3]) 
        : inputBuffer.reshape([1, _inputSize, _inputSize, 3]);

    // 3. Prepare output tensor
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputIsQuantized = outputTensor.type == TensorType.uint8 || outputTensor.type == TensorType.int8;
    
    // 5 classes
    var outputBuffer = List.filled(5, 0.0).reshape([1, 5]);
    var outputIntBuffer = List.filled(5, 0).reshape([1, 5]);

    // 4. Run Inference
    if (outputIsQuantized) {
       _interpreter!.run(inputObj, outputIntBuffer);
    } else {
       _interpreter!.run(inputObj, outputBuffer);
    }

    // 5. Find highest confidence
    int bestIndex = 0;
    double highestProb = 0.0;
    
    for (int i = 0; i < 5; i++) {
      double prob = outputIsQuantized ? outputIntBuffer[0][i] / 255.0 : outputBuffer[0][i];
      if (prob > highestProb) {
        highestProb = prob;
        bestIndex = i;
      }
    }

    final label = _labels != null && bestIndex < _labels!.length ? _labels![bestIndex] : "Unknown";
    return ClassificationResult(label, bestIndex, highestProb);
  }

  // CameraImage to Image conversion
  img.Image? _convertCameraImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420ToImage(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: image.planes[0].bytes.buffer,
        order: img.ChannelOrder.bgra,
      );
    }
    return null;
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel!;
    
    final imgImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      int pY = y * image.planes[0].bytesPerRow;
      int pUV = (y >> 1) * uvRowStride;

      for (int x = 0; x < width; x++) {
        int uvOffset = pUV + (x >> 1) * uvPixelStride;
        
        final yp = image.planes[0].bytes[pY + x];
        final up = image.planes[1].bytes[uvOffset];
        final vp = image.planes[2].bytes[uvOffset];
        
        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        imgImage.setPixelRgb(x, y, 
            r.clamp(0, 255), 
            g.clamp(0, 255), 
            b.clamp(0, 255));
      }
    }
    return imgImage;
  }
}

