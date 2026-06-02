import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserLocation {
  final String? village, district, state;
  UserLocation({this.village, this.district, this.state});
  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
        village: json['village'],
        district: json['district'],
        state: json['state'],
      );
}

class FarmDetails {
  final double? landArea;
  final String? soilType;
  final String? irrigationType;
  final List<String>? crops;
  FarmDetails({this.landArea, this.soilType, this.irrigationType, this.crops});
  factory FarmDetails.fromJson(Map<String, dynamic> json) {
    // Attempt to read crops from json['crops'], fallback to 'cropTypes'
    var rawCrops = json['crops'] ?? json['cropTypes'];
    List<String>? cropList;
    if (rawCrops != null && rawCrops is List) {
      if (rawCrops.isNotEmpty && rawCrops.first is Map) {
        cropList = rawCrops.map((e) => e['name'].toString()).toList();
      } else {
        cropList = rawCrops.map((e) => e.toString()).toList();
      }
    }
    
    return FarmDetails(
      landArea: json['farmSize']?.toDouble() ?? json['landArea']?.toDouble(),
      soilType: json['soilType'],
      irrigationType: json['irrigationType'],
      crops: cropList,
    );
  }
}

class AppUser {
  final String id, name;
  final String? email, phone, preferredLanguage;
  final UserLocation? location;
  final FarmDetails? farmDetails;

  AppUser({required this.id, required this.name, this.email, this.phone, this.preferredLanguage, this.location, this.farmDetails});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phoneNumber'] ?? json['phone'],
      location: UserLocation(
        village: json['village'] ?? json['location']?['village'],
        district: json['district'] ?? json['location']?['district'],
        state: json['state'] ?? json['location']?['state'],
      ),
      farmDetails: (json['farmDetails'] != null || json['farmSize'] != null || json['landArea'] != null)
          ? FarmDetails.fromJson(json['farmDetails'] ?? json)
          : null,
      preferredLanguage: json['preferredLanguage'],
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();
  AppUser? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.login(email, password);
      if (data['success'] == true) {
        _user = AppUser.fromJson(data['user']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = data['error'] ?? data['message'] ?? 'Login failed';
    } catch (e) {
      _error = 'Connection error: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.register(userData);
      if (data['success'] == true) {
        _user = AppUser.fromJson(data['user']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = data['error'] ?? data['message'] ?? 'Registration failed';
    } catch (e) {
      _error = 'Connection error: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> firebaseSync(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.firebaseSync(phoneNumber);
      if (data['success'] == true) {
        _user = AppUser.fromJson(data['user']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = data['error'] ?? data['message'] ?? 'Sync failed';
    } catch (e) {
      _error = 'Connection error: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> checkAuth() async {
    try {
      final data = await _api.getProfile();
      if (data['success'] == true) {
        _user = AppUser.fromJson(data['user'] ?? data['data']);
        _isAuthenticated = true;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/auth/update-profile', data);
      if (res['success'] == true) {
        _user = AppUser.fromJson(res['data']);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
