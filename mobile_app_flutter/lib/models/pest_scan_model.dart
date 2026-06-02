class PestScanModel {
  final String id;
  final String imageUrl;
  final String cropType;
  final String diseaseDetected;
  final double confidenceScore;
  final String treatmentSuggestion;
  final DateTime scanDate;

  PestScanModel({
    required this.id,
    required this.imageUrl,
    required this.cropType,
    required this.diseaseDetected,
    required this.confidenceScore,
    required this.treatmentSuggestion,
    required this.scanDate,
  });

  factory PestScanModel.fromJson(Map<String, dynamic> json) {
    return PestScanModel(
      id: json['_id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      cropType: json['cropType'] ?? 'Unknown',
      diseaseDetected: json['diseaseDetected'] ?? 'Healthy',
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      treatmentSuggestion: json['treatmentSuggestion'] ?? '',
      scanDate: json['scanDate'] != null ? DateTime.parse(json['scanDate']) : DateTime.now(),
    );
  }
}
