import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class WeatherService {
  final String _baseUrl = AppConstants.backendBaseUrl;

  Future<Map<String, dynamic>> getWeather(String location) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/weather/$location'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<List<dynamic>> getForecast(String location) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/weather/$location/forecast'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load forecast');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }
}
