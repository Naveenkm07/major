import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
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
        _user = UserModel.fromJson(data['user']);
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
        _user = UserModel.fromJson(data['user']);
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
        _user = UserModel.fromJson(data['user']);
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
        _user = UserModel.fromJson(data['user'] ?? data['data']);
        _isAuthenticated = true;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/auth/update-profile', data);
      if (res['success'] == true) {
        _user = UserModel.fromJson(res['data']);
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

  Future<void> toggleSchemeBookmark(String schemeId) async {
    if (_user == null) return;
    
    // Optimistic UI update
    final savedSchemes = List<String>.from(_user!.savedSchemes);
    if (savedSchemes.contains(schemeId)) {
      savedSchemes.remove(schemeId);
    } else {
      savedSchemes.add(schemeId);
    }
    
    // Update local user state
    _user = UserModel(
      id: _user!.id,
      name: _user!.name,
      email: _user!.email,
      phone: _user!.phone,
      role: _user!.role,
      avatar: _user!.avatar,
      location: _user!.location,
      farmDetails: _user!.farmDetails,
      stats: _user!.stats,
      savedSchemes: savedSchemes,
      savedEquipment: _user!.savedEquipment,
    );
    notifyListeners();

    try {
      await _api.toggleSchemeBookmark(schemeId);
    } catch (e) {
      debugPrint('Error toggling scheme bookmark: $e');
    }
  }

  Future<void> toggleEquipmentBookmark(String equipmentId) async {
    if (_user == null) return;
    
    // Optimistic UI update
    final savedEquipment = List<String>.from(_user!.savedEquipment);
    if (savedEquipment.contains(equipmentId)) {
      savedEquipment.remove(equipmentId);
    } else {
      savedEquipment.add(equipmentId);
    }
    
    // Update local user state
    _user = UserModel(
      id: _user!.id,
      name: _user!.name,
      email: _user!.email,
      phone: _user!.phone,
      role: _user!.role,
      avatar: _user!.avatar,
      location: _user!.location,
      farmDetails: _user!.farmDetails,
      stats: _user!.stats,
      savedSchemes: _user!.savedSchemes,
      savedEquipment: savedEquipment,
    );
    notifyListeners();

    try {
      await _api.toggleEquipmentBookmark(equipmentId);
    } catch (e) {
      debugPrint('Error toggling equipment bookmark: $e');
    }
  }
}
