import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/services/tflite_service.dart';

void main() {
  group('TFLiteService Unit Tests', () {
    late TFLiteService service;

    setUp(() {
      service = TFLiteService();
    });

    test('IoU calculation', () {
      final rectA = const Rect.fromLTWH(0, 0, 100, 100);
      final rectB = const Rect.fromLTWH(50, 50, 100, 100);

      // Area A = 10000, Area B = 10000
      // Intersection = 50 * 50 = 2500
      // Union = 20000 - 2500 = 17500
      // IoU = 2500 / 17500 = 0.142857
      
      final iou = service.calculateIoU(rectA, rectB);
      expect(iou, closeTo(0.142857, 0.001));

      // Perfect overlap
      final iouPerfect = service.calculateIoU(rectA, rectA);
      expect(iouPerfect, equals(1.0));

      // No overlap
      final rectC = const Rect.fromLTWH(200, 200, 100, 100);
      final iouNone = service.calculateIoU(rectA, rectC);
      expect(iouNone, equals(0.0));
    });

    test('NMS filtering logic', () {
      // Detection A: class 2, conf 0.90
      final detA = Detection('rust', 0.90, const Rect.fromLTWH(0, 0, 100, 100));
      // Detection B: class 2, conf 0.80 (highly overlapping with A)
      final detB = Detection('rust', 0.80, const Rect.fromLTWH(10, 10, 100, 100)); // IoU is very high
      // Detection C: class 3, conf 0.85 (highly overlapping with A but DIFFERENT class)
      final detC = Detection('leaf_spot', 0.85, const Rect.fromLTWH(10, 10, 100, 100));

      List<Detection> input = [detB, detA, detC];

      final results = service.applyNMS(input);
      
      // Expected: A survives (highest conf), B is suppressed (same class, high overlap), C survives (different class)
      expect(results.length, equals(2));
      expect(results[0].label, equals('rust'));
      expect(results[0].confidence, equals(0.90));
      expect(results[1].label, equals('leaf_spot'));
      expect(results[1].confidence, equals(0.85));
    });

    test('Letterboxing calculations', () {
      // 1080x1920 portrait image mapped into 640x640 tensor
      final lbPortrait = service.computeLetterboxInfo(1080, 1920, 640);
      // scale = 640 / 1920 = 0.333333
      // newW = 1080 * 0.33333 = 360
      // padX = (640 - 360) / 2 = 140
      
      expect(lbPortrait.scale, closeTo(0.333333, 0.001));
      expect(lbPortrait.padX, equals(140));
      expect(lbPortrait.padY, equals(0));

      // 1920x1080 landscape image mapped into 640x640 tensor
      final lbLandscape = service.computeLetterboxInfo(1920, 1080, 640);
      expect(lbLandscape.scale, closeTo(0.333333, 0.001));
      expect(lbLandscape.padX, equals(0));
      expect(lbLandscape.padY, equals(140));
    });
  });
}
