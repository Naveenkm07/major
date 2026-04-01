/// Pest scan result model matching PestScan Mongoose schema
class ScanModel {
  final String id;
  final String pest;
  final double confidence;
  final String? description;
  final List<String> treatment;
  final List<String> prevention;
  final String? imageUrl;
  final DateTime scanDate;

  ScanModel({
    required this.id,
    required this.pest,
    required this.confidence,
    this.description,
    this.treatment = const [],
    this.prevention = const [],
    this.imageUrl,
    DateTime? scanDate,
  }) : scanDate = scanDate ?? DateTime.now();

  factory ScanModel.fromJson(Map<String, dynamic> json) => ScanModel(
        id: json['scanId'] ?? json['_id'] ?? '',
        pest: json['pest'] ?? json['diseaseDetected'] ?? 'unknown',
        confidence: (json['confidence'] ?? json['confidenceScore'] ?? 0).toDouble(),
        description: json['description'],
        treatment: (json['treatment'] as List?)?.map((e) => e.toString()).toList() ?? [],
        prevention: (json['prevention'] as List?)?.map((e) => e.toString()).toList() ?? [],
        imageUrl: json['imageUrl'] ?? json['image_url'],
        scanDate: json['scanDate'] != null ? DateTime.tryParse(json['scanDate']) ?? DateTime.now() : DateTime.now(),
      );
}
