import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _forecast;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentWeather => _currentWeather;
  List<dynamic>? get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(String location) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getWeather(location);
      _forecast = await _weatherService.getForecast(location);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
