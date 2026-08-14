import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Inspect TFLite Metadata and Run Inference', () async {
    final modelPath = 'assets/models/crop_disease_classifier_int8.tflite';
    
    // Check if model exists
    final file = File(modelPath);
    if (!file.existsSync()) {
      print('ERROR: TFLite model not found at $modelPath');
      return;
    }

    final interpreter = await Interpreter.fromFile(file);
    
    // 1. Inspect Metadata
    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);

    print('--- TFLite Metadata ---');
    print('Input Shape: ${inputTensor.shape}');
    print('Input Type: ${inputTensor.type}');
    print('Input Scale: ${inputTensor.params.scale}');
    print('Input ZeroPoint: ${inputTensor.params.zeroPoint}');
    
    print('Output Shape: ${outputTensor.shape}');
    print('Output Type: ${outputTensor.type}');
    print('Output Scale: ${outputTensor.params.scale}');
    print('Output ZeroPoint: ${outputTensor.params.zeroPoint}');
    
    expect(inputTensor.shape.length, 4);
    expect(outputTensor.shape, [1, 25]);
    
    // Load Labels
    final labelsFile = File('assets/models/disease_labels.txt');
    final labels = labelsFile.readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();
    expect(labels.length, 25);
    
    // 2. Run Inference on Test Dataset
    final testDir = Directory('../dataset_split/test');
    if (!testDir.existsSync()) {
      print('ERROR: Test directory not found');
      return;
    }

    final inputSize = 224;
    final results = <String, dynamic>{};
    int count = 0;

    for (var classDir in testDir.listSync().whereType<Directory>()) {
      final className = classDir.uri.pathSegments[classDir.uri.pathSegments.length - 2];
      
      for (var imgFile in classDir.listSync().whereType<File>()) {
        if (count >= 100) break; // Limit to 100 for speed
        
        final bytes = imgFile.readAsBytesSync();
        final image = img.decodeImage(bytes);
        if (image == null) continue;

        // Resize
        final resized = img.copyResize(image, width: inputSize, height: inputSize);
        
        // Input Tensor format (quantized)
        var inputBuffer = Uint8List(1 * inputSize * inputSize * 3);
        var byteData = ByteData.view(inputBuffer.buffer);
        int pixelIndex = 0;
        
        final isInt8 = inputTensor.type == TensorType.int8;

        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            final pixel = resized.getPixel(x, y);
            
            int quantize(num value) {
              double real = value.toDouble();
              int q = (real / inputTensor.params.scale + inputTensor.params.zeroPoint).round();
              return isInt8 ? q.clamp(-128, 127) : q.clamp(0, 255);
            }

            if (isInt8) {
              byteData.setInt8(pixelIndex++, quantize(pixel.r));
              byteData.setInt8(pixelIndex++, quantize(pixel.g));
              byteData.setInt8(pixelIndex++, quantize(pixel.b));
            } else {
              byteData.setUint8(pixelIndex++, quantize(pixel.r));
              byteData.setUint8(pixelIndex++, quantize(pixel.g));
              byteData.setUint8(pixelIndex++, quantize(pixel.b));
            }
          }
        }

        // Output Buffer
        var outputBuffer = isInt8 ? List.filled(25, 0) : List.filled(25, 0); // int8
        
        // Run
        interpreter.run(inputBuffer, [outputBuffer]);

        // Dequantize
        var floatOutputs = List<double>.filled(25, 0.0);
        for (int i = 0; i < 25; i++) {
          floatOutputs[i] = (outputBuffer[i] - outputTensor.params.zeroPoint) * outputTensor.params.scale;
        }

        // Softmax
        double maxVal = floatOutputs.reduce(max);
        var expVals = floatOutputs.map((v) => exp(v - maxVal)).toList();
        double sumExp = expVals.reduce((a, b) => a + b);
        var probs = expVals.map((v) => v / sumExp).toList();

        // Top prediction
        int maxIdx = 0;
        double maxProb = probs[0];
        for (int i = 1; i < 25; i++) {
          if (probs[i] > maxProb) {
            maxProb = probs[i];
            maxIdx = i;
          }
        }

        results[imgFile.path] = {
          'true_class': className,
          'tflite': {
            'class': labels[maxIdx],
            'confidence': maxProb
          }
        };
        count++;
      }
    }

    File('../ml/disease_detection/output/tflite_results.json').writeAsStringSync(jsonEncode(results));
    print('TFLite inference completed on $count images. Saved to tflite_results.json');
  });
}
