class CropModel {
  final String id;
  final String name;
  final String? localName;
  final String category;
  final String season;
  final String? description;
  final int? growthDuration;
  final String? imageUrl;
  final List<CalendarStage>? calendar;

  CropModel({
    required this.id,
    required this.name,
    this.localName,
    required this.category,
    required this.season,
    this.description,
    this.growthDuration,
    this.imageUrl,
    this.calendar,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      localName: json['localName'],
      category: json['category'] ?? '',
      season: json['season'] ?? '',
      description: json['description'],
      growthDuration: json['growthDuration'],
      imageUrl: json['imageUrl'],
      calendar: json['calendar'] != null
          ? (json['calendar'] as List).map((e) => CalendarStage.fromJson(e)).toList()
          : null,
    );
  }
}

class CalendarStage {
  final String stage;
  final int startWeek;
  final int endWeek;
  final List<String> activities;
  final List<String> tips;

  CalendarStage({
    required this.stage,
    required this.startWeek,
    required this.endWeek,
    required this.activities,
    required this.tips,
  });

  factory CalendarStage.fromJson(Map<String, dynamic> json) {
    return CalendarStage(
      stage: json['stage'] ?? '',
      startWeek: json['startWeek'] ?? 0,
      endWeek: json['endWeek'] ?? 0,
      activities: List<String>.from(json['activities'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
    );
  }
}
