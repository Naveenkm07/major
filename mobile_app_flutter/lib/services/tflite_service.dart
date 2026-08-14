import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class Detection {
  final String label;
  final double confidence;
  final Rect boundingBox;

  Detection(this.label, this.confidence, this.boundingBox);
}

class LetterboxInfo {
  final double scale;
  final int padX;
  final int padY;
  LetterboxInfo(this.scale, this.padX, this.padY);
}

// Tensor Layout Enums
enum TensorLayout {
  channelsFirst, // [1, Elements, Anchors] (e.g. 1, 42, 8400)
  anchorsFirst,  // [1, Anchors, Elements] (e.g. 1, 8400, 42)
  unknown
}

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;
  
  // Dynamic Tensor Metadata
  int _inputSize = 0;
  int _numClasses = 0;
  int _numAnchors = 0;
  int _outputElements = 0;
  TensorLayout _outputLayout = TensorLayout.unknown;
  
  double _inputScale = 1.0;
  int _inputZeroPoint = 0;
  TensorType _inputType = TensorType.float32;

  double _outputScale = 1.0;
  int _outputZeroPoint = 0;
  TensorType _outputType = TensorType.float32;

  // Configuration
  final double confidenceThreshold = 0.5;
  final double iouThreshold = 0.45;

  bool get isLoaded => _interpreter != null;
  bool get hasValidMetadata => _inputSize > 0 && _numClasses > 0;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      if (Platform.isAndroid) {
        options.addDelegate(XNNPackDelegate());
      } else if (Platform.isIOS) {
        options.addDelegate(GpuDelegate());
      }
      
      _interpreter = await Interpreter.fromAsset('assets/models/yolov8_int8.tflite', options: options);
      
      _extractTensorMetadata();
      await _loadLabels();
      _validateCompatibility();
      
      print('TFLite model loaded successfully');
      print('Input Shape: $_inputSize x $_inputSize');
      print('Classes: $_numClasses');
      print('Layout: $_outputLayout');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  void _extractTensorMetadata() {
    if (_interpreter == null) return;
    
    // Extract Input Metadata
    final inputTensor = _interpreter!.getInputTensor(0);
    final inputShape = inputTensor.shape; 
    if (inputShape.length == 4) {
      _inputSize = inputShape[1];
    } else {
      throw StateError("Invalid input tensor shape: $inputShape");
    }
    _inputType = inputTensor.type;
    _inputScale = inputTensor.params.scale == 0.0 ? 1.0 : inputTensor.params.scale;
    _inputZeroPoint = inputTensor.params.zeroPoint;

    // Extract Output Metadata
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape; 
    
    if (outputShape.length == 3) {
      // Determine layout based on typical YOLOv8 dimensionalities
      if (outputShape[1] < outputShape[2]) {
        // [1, Elements, Anchors]
        _outputLayout = TensorLayout.channelsFirst;
        _outputElements = outputShape[1];
        _numAnchors = outputShape[2];
      } else {
        // [1, Anchors, Elements]
        _outputLayout = TensorLayout.anchorsFirst;
        _numAnchors = outputShape[1];
        _outputElements = outputShape[2];
      }
      _numClasses = _outputElements - 4;
    } else {
      throw StateError("Invalid output tensor shape: $outputShape. Expected YOLOv8 rank-3 tensor.");
    }
    
    _outputType = outputTensor.type;
    _outputScale = outputTensor.params.scale == 0.0 ? 1.0 : outputTensor.params.scale;
    _outputZeroPoint = outputTensor.params.zeroPoint;
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/disease_labels.txt');
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch (e) {
      throw StateError('Failed to load disease_labels.txt: $e');
    }
  }

  void _validateCompatibility() {
    if (_labels == null) {
      throw StateError('Labels not loaded.');
    }
    if (_labels!.length != _numClasses) {
      throw StateError('Model class count $_numClasses does not match label count ${_labels!.length}.');
    }
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<List<Detection>> detectFromFile(String imagePath) async {
    if (!isLoaded || !hasValidMetadata) return [];
    
    try {
      final bytes = await File(imagePath).readAsBytes();
      final rgbImage = img.decodeImage(bytes);
      if (rgbImage == null) return [];
      
      return _runInference(rgbImage);
    } catch (e) {
      print('Error decoding gallery image: $e');
      return [];
    }
  }

  Future<List<Detection>> detect(CameraImage cameraImage) async {
    if (!isLoaded || !hasValidMetadata) return [];

    final rgbImage = _convertCameraImage(cameraImage);
    if (rgbImage == null) return [];

    return _runInference(rgbImage);
  }

  // Exposed for unit testing letterbox math
  LetterboxInfo computeLetterboxInfo(int imgWidth, int imgHeight, int targetSize) {
    double scale = min(targetSize / imgWidth, targetSize / imgHeight);
    int newWidth = (imgWidth * scale).round();
    int newHeight = (imgHeight * scale).round();
    
    int padX = ((targetSize - newWidth) / 2).round();
    int padY = ((targetSize - newHeight) / 2).round();
    
    return LetterboxInfo(scale, padX, padY);
  }

  Future<List<Detection>> _runInference(img.Image rgbImage) async {
    // 1. Letterbox Preprocessing
    final lbInfo = computeLetterboxInfo(rgbImage.width, rgbImage.height, _inputSize);
    final letterboxedImage = _applyLetterbox(rgbImage, lbInfo);
    
    // 2. Format Input Tensor
    Object inputTensor;
    if (_inputType == TensorType.uint8 || _inputType == TensorType.int8) {
      inputTensor = _imageToByteListQuantized(letterboxedImage);
    } else {
      inputTensor = _imageToFloat32List(letterboxedImage);
    }

    // 3. Format Output Buffer
    var outputTensor = List.filled(_outputElements * _numAnchors, 0.0);
    var outputBuffer;
    if (_outputLayout == TensorLayout.channelsFirst) {
      outputBuffer = outputTensor.reshape([1, _outputElements, _numAnchors]);
    } else {
      outputBuffer = outputTensor.reshape([1, _numAnchors, _outputElements]);
    }

    // 4. Run inference
    _interpreter!.run(inputTensor, outputBuffer);

    // 5. Parse outputs & Revert Letterbox
    return _parseOutput(outputBuffer[0], rgbImage.width, rgbImage.height, lbInfo);
  }

  img.Image _applyLetterbox(img.Image source, LetterboxInfo lb) {
    int newWidth = (source.width * lb.scale).round();
    int newHeight = (source.height * lb.scale).round();
    
    img.Image resized = img.copyResize(source, width: newWidth, height: newHeight);
    
    // Create a grey canvas (114, 114, 114) typical for YOLO
    img.Image canvas = img.Image(width: _inputSize, height: _inputSize);
    canvas.clear(img.ColorRgb8(114, 114, 114));
    
    img.compositeImage(canvas, resized, dstX: lb.padX, dstY: lb.padY);
    return canvas;
  }
  
  List<Detection> _parseOutput(List<dynamic> output, int imgWidth, int imgHeight, LetterboxInfo lb) {
    List<Detection> detections = [];

    for (int i = 0; i < _numAnchors; i++) {
      double maxClassProb = 0.0;
      int maxClassIdx = -1;
      
      // Dynamic extraction based on layout
      double getRawOutput(int channelIndex, int anchorIndex) {
        if (_outputLayout == TensorLayout.channelsFirst) {
          return _dequantizeOutput(output[channelIndex][anchorIndex]);
        } else {
          return _dequantizeOutput(output[anchorIndex][channelIndex]);
        }
      }

      for (int c = 0; c < _numClasses; c++) {
        double prob = getRawOutput(4 + c, i);
        if (prob > maxClassProb) {
          maxClassProb = prob;
          maxClassIdx = c;
        }
      }

      if (maxClassProb > confidenceThreshold) {
        double xc = getRawOutput(0, i);
        double yc = getRawOutput(1, i);
        double w = getRawOutput(2, i);
        double h = getRawOutput(3, i);

        // Remove letterbox padding
        double unpaddedXc = xc - lb.padX;
        double unpaddedYc = yc - lb.padY;

        // Scale back to original image
        double originalXc = unpaddedXc / lb.scale;
        double originalYc = unpaddedYc / lb.scale;
        double originalW = w / lb.scale;
        double originalH = h / lb.scale;

        final rect = Rect.fromCenter(
          center: Offset(originalXc, originalYc),
          width: originalW,
          height: originalH,
        );

        final label = (_labels != null && maxClassIdx < _labels!.length) 
            ? _labels![maxClassIdx] 
            : 'unknown';

        detections.add(Detection(label, maxClassProb, rect));
      }
    }
    
    return applyNMS(detections);
  }

  double _dequantizeOutput(dynamic value) {
    if (value is int) {
      return (value.toDouble() - _outputZeroPoint) * _outputScale;
    } else if (value is double) {
      return value;
    }
    return 0.0;
  }

  // Exposed for unit testing
  List<Detection> applyNMS(List<Detection> detections) {
    if (detections.isEmpty) return [];
    
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    List<Detection> finalDetections = [];
    
    while (detections.isNotEmpty) {
      final current = detections.removeAt(0);
      finalDetections.add(current);
      
      detections.removeWhere((candidate) {
        if (candidate.label == current.label) {
          final iou = calculateIoU(current.boundingBox, candidate.boundingBox);
          return iou > iouThreshold;
        }
        return false;
      });
    }
    
    return finalDetections;
  }

  // Exposed for unit testing
  double calculateIoU(Rect a, Rect b) {
    final intersection = a.intersect(b);
    if (intersection.width < 0 || intersection.height < 0) return 0.0;
    
    final intersectionArea = intersection.width * intersection.height;
    final unionArea = (a.width * a.height) + (b.width * b.height) - intersectionArea;
    
    return intersectionArea / unionArea;
  }

  Uint8List _imageToByteListQuantized(img.Image image) {
    var convertedBytes = Uint8List(1 * _inputSize * _inputSize * 3);
    var buffer = ByteData.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        
        int quantize(num value) {
          double real = value.toDouble();
          int q = (real / _inputScale + _inputZeroPoint).round();
          if (_inputType == TensorType.int8) {
            return q.clamp(-128, 127);
          } else {
            return q.clamp(0, 255);
          }
        }

        if (_inputType == TensorType.int8) {
          buffer.setInt8(pixelIndex++, quantize(pixel.r));
          buffer.setInt8(pixelIndex++, quantize(pixel.g));
          buffer.setInt8(pixelIndex++, quantize(pixel.b));
        } else {
          buffer.setUint8(pixelIndex++, quantize(pixel.r));
          buffer.setUint8(pixelIndex++, quantize(pixel.g));
          buffer.setUint8(pixelIndex++, quantize(pixel.b));
        }
      }
    }
    return convertedBytes;
  }

  Float32List _imageToFloat32List(img.Image image) {
    var convertedBytes = Float32List(1 * _inputSize * _inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
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
