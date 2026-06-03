import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<bool> phoneSync(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.phoneSync(phoneNumber);
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

  Future<bool> supabaseGoogleSignIn() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
        // For web, the browser will redirect to Google's sign-in page.
        // We just return true as the flow continues on the new page.
        return true;
      } else {
        const webClientId = '579437156136-o5f2pcerepk40c3q2lcst8tn9fm0e260.apps.googleusercontent.com';
        
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize(
          serverClientId: webClientId,
        );
        final googleUser = await googleSignIn.authenticate();
        
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null) {
          _error = 'Google Auth Failed: Missing tokens';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final AuthResponse response = await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );

        if (response.user != null) {
          final data = await _api.googleSync(googleUser.email, googleUser.displayName ?? 'Google Farmer');
          if (data['success'] == true) {
            _user = UserModel.fromJson(data['user']);
            _isAuthenticated = true;
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
             _error = data['error'] ?? data['message'] ?? 'Google Sync Failed';
          }
        }
      }
    } catch (e) {
      _error = 'Google Sign-In Error: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
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
