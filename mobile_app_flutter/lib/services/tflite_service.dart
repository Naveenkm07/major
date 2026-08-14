import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ClassificationResult {
  final String label;
  final int classIndex;
  final double confidence;

  ClassificationResult(this.label, this.classIndex, this.confidence);
}

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;
  
  // Dynamic Tensor Metadata
  int _inputSize = 0;
  int _numClasses = 0;
  
  double _inputScale = 1.0;
  int _inputZeroPoint = 0;
  TensorType _inputType = TensorType.float32;

  double _outputScale = 1.0;
  int _outputZeroPoint = 0;
  TensorType _outputType = TensorType.float32;

  final double confidenceThreshold = 0.50;

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
      
      // Use the actual trained classifier model
      _interpreter = await Interpreter.fromAsset('assets/models/crop_disease_classifier_int8.tflite', options: options);
      
      _extractTensorMetadata();
      await _loadLabels();
      _validateCompatibility();
      
      print('TFLite classifier loaded successfully');
      print('Input Shape: $_inputSize x $_inputSize');
      print('Classes: $_numClasses');
    } catch (e) {
      print('Failed to load classifier model: $e');
    }
  }

  void _extractTensorMetadata() {
    if (_interpreter == null) return;
    
    // Extract Input Metadata
    final inputTensor = _interpreter!.getInputTensor(0);
    final inputShape = inputTensor.shape; 
    if (inputShape.length == 4) {
      // Expected [1, H, W, 3] or [1, 3, H, W]
      _inputSize = inputShape[1] > 3 ? inputShape[1] : inputShape[2];
    } else {
      throw StateError("Invalid input tensor shape: $inputShape");
    }
    _inputType = inputTensor.type;
    _inputScale = inputTensor.params.scale == 0.0 ? 1.0 : inputTensor.params.scale;
    _inputZeroPoint = inputTensor.params.zeroPoint;

    // Extract Output Metadata
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape; 
    
    if (outputShape.length == 2 && outputShape[0] == 1) {
      // Classification shape [1, num_classes]
      _numClasses = outputShape[1];
    } else {
      throw StateError("Invalid output tensor shape: $outputShape. Expected classifier rank-2 tensor [1, N].");
    }
    
    _outputType = outputTensor.type;
    _outputScale = outputTensor.params.scale == 0.0 ? 1.0 : outputTensor.params.scale;
    _outputZeroPoint = outputTensor.params.zeroPoint;
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/disease_labels.txt');
      _labels = labelData.split('\n').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
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

  Future<ClassificationResult?> detectFromFile(String imagePath) async {
    if (!isLoaded || !hasValidMetadata) return null;
    
    try {
      final bytes = await File(imagePath).readAsBytes();
      final rgbImage = img.decodeImage(bytes);
      if (rgbImage == null) return null;
      
      return _runInference(rgbImage);
    } catch (e) {
      print('Error decoding gallery image: $e');
      return null;
    }
  }

  Future<ClassificationResult?> detect(CameraImage cameraImage) async {
    if (!isLoaded || !hasValidMetadata) return null;

    final rgbImage = _convertCameraImage(cameraImage);
    if (rgbImage == null) return null;

    return _runInference(rgbImage);
  }

  Future<ClassificationResult?> _runInference(img.Image rgbImage) async {
    // 1. Classification Preprocessing: Resize and CenterCrop to inputSize x inputSize
    int minDim = min(rgbImage.width, rgbImage.height);
    img.Image cropped = img.copyCrop(rgbImage, 
      x: (rgbImage.width - minDim) ~/ 2, 
      y: (rgbImage.height - minDim) ~/ 2, 
      width: minDim, 
      height: minDim);
    
    img.Image resized = img.copyResize(cropped, width: _inputSize, height: _inputSize);

    // 2. Format Input Tensor
    Object inputTensor;
    if (_inputType == TensorType.uint8 || _inputType == TensorType.int8) {
      inputTensor = _imageToByteListQuantized(resized);
    } else {
      inputTensor = _imageToFloat32List(resized);
    }

    // 3. Format Output Buffer
    var outputBuffer = List.filled(1 * _numClasses, 0.0);
    if (_outputType == TensorType.int8 || _outputType == TensorType.uint8) {
        var outputTensor = List.filled(1 * _numClasses, 0);
        _interpreter!.run(inputTensor, [outputTensor]);
        for(int i=0; i<_numClasses; i++) {
           outputBuffer[i] = _dequantizeOutput(outputTensor[i]);
        }
    } else {
        _interpreter!.run(inputTensor, [outputBuffer]);
    }

    // 4. Parse outputs (Softmax if output does not sum to 1.0 approx)
    return _parseOutput(outputBuffer);
  }

  ClassificationResult? _parseOutput(List<double> output) {
    // Check if we need softmax (if max val > 1.0 or sum != 1.0)
    double sum = output.fold(0.0, (p, c) => p + c);
    List<double> probabilities = output;
    
    if (sum < 0.99 || sum > 1.01) {
        // Apply Softmax
        double maxVal = output.reduce(max);
        double expSum = 0.0;
        List<double> expValues = [];
        for (var v in output) {
           double e = exp(v - maxVal);
           expValues.add(e);
           expSum += e;
        }
        probabilities = expValues.map((e) => e / expSum).toList();
    }

    int maxIdx = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < _numClasses; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIdx = i;
      }
    }

    if (maxProb > confidenceThreshold) {
      return ClassificationResult(_labels![maxIdx], maxIdx, maxProb);
    }
    
    return null; // Return null if below confidence
  }

  double _dequantizeOutput(dynamic value) {
    if (value is int) {
      return (value.toDouble() - _outputZeroPoint) * _outputScale;
    } else if (value is double) {
      return value;
    }
    return 0.0;
  }

  Uint8List _imageToByteListQuantized(img.Image image) {
    var convertedBytes = Uint8List(1 * _inputSize * _inputSize * 3);
    var buffer = ByteData.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        
        int quantize(num value) {
          // Training used ImageNet normalization:
          // mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225]
          // But our INT8 model input scale/zero_point handle the [0, 255] -> INT8 mapping if exported properly.
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
        // Normalize using ImageNet means since model was trained that way
        buffer[pixelIndex++] = ((pixel.r / 255.0) - 0.485) / 0.229;
        buffer[pixelIndex++] = ((pixel.g / 255.0) - 0.456) / 0.224;
        buffer[pixelIndex++] = ((pixel.b / 255.0) - 0.406) / 0.225;
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
