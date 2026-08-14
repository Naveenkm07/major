import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Detection {
  final String label;
  final double confidence;
  final Rect boundingBox;

  Detection(this.label, this.confidence, this.boundingBox);
}

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;
  
  static const int inputSize = 640;
  static const int numClasses = 8;
  static const int numCoords = 4;
  static const int outputElements = numClasses + numCoords; // 12
  static const int numAnchors = 8400;

  bool get isLoaded => _interpreter != null;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      if (Platform.isAndroid) {
        options.addDelegate(XNNPackDelegate());
      } else if (Platform.isIOS) {
        options.addDelegate(GpuDelegate());
      }
      
      _interpreter = await Interpreter.fromAsset('assets/models/yolov8_int8.tflite', options: options);
      await _loadLabels();
      print('TFLite model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/disease_labels.txt');
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch (e) {
      print('Error loading labels: $e');
      _labels = ['healthy', 'bacterial_blight', 'leaf_spot', 'rust', 'powdery_mildew', 'late_blight', 'aphids', 'stem_borer'];
    }
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<List<Detection>> detect(CameraImage cameraImage) async {
    if (_interpreter == null) return [];

    // 1. Convert CameraImage to RGB Image
    final rgbImage = _convertCameraImage(cameraImage);
    if (rgbImage == null) return [];

    // 2. Resize and normalize
    final resizedImage = img.copyResize(rgbImage, width: inputSize, height: inputSize);
    final inputTensor = _imageToByteListInt8(resizedImage);

    // 3. Output tensor shape: [1, 12, 8400] for 8 classes
    final outputShape = _interpreter!.getOutputTensor(0).shape; // e.g. [1, 12, 8400]
    final outputTensor = List.filled(outputShape[1] * outputShape[2], 0.0);
    var outputBuffer = outputTensor.reshape([1, outputElements, numAnchors]);

    // 4. Run inference
    _interpreter!.run(inputTensor, outputBuffer);

    // 5. Parse outputs (mock processing, normally needs NMS)
    return _parseOutput(outputBuffer[0], rgbImage.width, rgbImage.height);
  }
  
  List<Detection> _parseOutput(List<dynamic> output, int imgWidth, int imgHeight) {
    List<Detection> detections = [];
    final threshold = 0.5;

    // Output shape is [12, 8400] -> [4 coords + 8 classes, 8400 anchors]
    for (int i = 0; i < numAnchors; i++) {
      double maxClassProb = 0.0;
      int maxClassIdx = -1;
      
      // Find highest class probability for this anchor
      for (int c = 0; c < numClasses; c++) {
        // Depending on model quantization, this might need dequantization
        double prob = (output[4 + c][i] is int) 
            ? (output[4 + c][i] as int).toDouble() / 255.0 
            : (output[4 + c][i] as double);
            
        if (prob > maxClassProb) {
          maxClassProb = prob;
          maxClassIdx = c;
        }
      }

      if (maxClassProb > threshold) {
        // Bounding box mapping (xc, yc, w, h)
        double xc = (output[0][i] is int) ? (output[0][i] as int).toDouble() : output[0][i];
        double yc = (output[1][i] is int) ? (output[1][i] as int).toDouble() : output[1][i];
        double w = (output[2][i] is int) ? (output[2][i] as int).toDouble() : output[2][i];
        double h = (output[3][i] is int) ? (output[3][i] as int).toDouble() : output[3][i];

        // Normalize back to original image size
        double xCenter = (xc / inputSize) * imgWidth;
        double yCenter = (yc / inputSize) * imgHeight;
        double width = (w / inputSize) * imgWidth;
        double height = (h / inputSize) * imgHeight;

        final rect = Rect.fromCenter(
          center: Offset(xCenter, yCenter),
          width: width,
          height: height,
        );

        final label = (_labels != null && maxClassIdx < _labels!.length) 
            ? _labels![maxClassIdx] 
            : 'unknown';

        detections.add(Detection(label, maxClassProb, rect));
      }
    }
    
    // Perform simple NMS (Non-Maximum Suppression)
    return _applyNMS(detections);
  }

  List<Detection> _applyNMS(List<Detection> detections) {
    // Simple NMS mock - return highest confidence
    if (detections.isEmpty) return [];
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    return [detections.first]; // returning top 1 for now to prevent overlapping
  }

  Uint8List _imageToByteListInt8(img.Image image) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = ByteData.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        // Assuming INT8 model (-128 to 127)
        buffer.setInt8(pixelIndex++, pixel.r.toInt() - 128);
        buffer.setInt8(pixelIndex++, pixel.g.toInt() - 128);
        buffer.setInt8(pixelIndex++, pixel.b.toInt() - 128);
      }
    }
    return convertedBytes;
  }

  img.Image? _convertCameraImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420ToImage(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888ToImage(image);
    }
    return null;
  }

  img.Image _convertBGRA8888ToImage(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
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
