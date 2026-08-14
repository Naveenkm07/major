import 'package:flutter_test/flutter_test.dart';
import '../lib/services/tflite_service.dart';

void main() {
  group('TFLiteService Unit Tests', () {
    late TFLiteService service;

    setUp(() {
      service = TFLiteService();
    });

    test('Initial state is unloaded', () {
      expect(service.isLoaded, isFalse);
      expect(service.hasValidMetadata, isFalse);
    });
    
    test('ClassificationResult structure', () {
      final result = ClassificationResult('Corn___Healthy', 2, 0.95);
      
      expect(result.label, equals('Corn___Healthy'));
      expect(result.classIndex, equals(2));
      expect(result.confidence, closeTo(0.95, 0.001));
    });
  });
}
