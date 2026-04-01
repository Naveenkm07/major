import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CalendarStage {
  final String stage;
  final int startWeek, endWeek;
  final List<String> activities;

  CalendarStage({required this.stage, required this.startWeek, required this.endWeek, required this.activities});

  factory CalendarStage.fromJson(Map<String, dynamic> json) => CalendarStage(
        stage: json['stage'] ?? '',
        startWeek: json['startWeek'] ?? 0,
        endWeek: json['endWeek'] ?? 0,
        activities: (json['activities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class Crop {
  final String id, name, category;
  final int? growthDuration;
  final List<CalendarStage>? calendar;

  Crop({required this.id, required this.name, required this.category, this.growthDuration, this.calendar});

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json['_id'] ?? '',
        name: json['cropName'] ?? json['name'] ?? '',
        category: json['category'] ?? json['season'] ?? '',
        growthDuration: json['growthDuration'],
        calendar: (json['calendar'] as List?)?.map((e) => CalendarStage.fromJson(e)).toList(),
      );
}

class CropProvider extends ChangeNotifier {
  final _api = ApiService();
  List<Crop> _crops = [];
  bool _isLoading = false;

  List<Crop> get crops => _crops;
  bool get isLoading => _isLoading;

  Future<void> fetchCrops({String? season, String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getCrops(season: season, search: search);
      if (data['success'] == true) {
        _crops = (data['data'] as List).map((e) => Crop.fromJson(e)).toList();
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
