import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/equipment_model.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EquipmentProvider with ChangeNotifier {
  final String _baseUrl = AppConstants.backendBaseUrl;
  final _storage = const FlutterSecureStorage();

  List<EquipmentModel> _equipment = [];
  bool _isLoading = false;
  String? _error;

  List<EquipmentModel> get equipment => _equipment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEquipment({String? type, String? district}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String url = '$_baseUrl/equipment';
      Map<String, String> params = {};
      if (type != null && type != 'All') params['type'] = type;
      if (district != null) params['district'] = district;

      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _equipment = (data['data'] as List).map((e) => EquipmentModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load equipment');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEquipment(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      final response = await http.post(
        Uri.parse('$_baseUrl/equipment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        await fetchEquipment();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
