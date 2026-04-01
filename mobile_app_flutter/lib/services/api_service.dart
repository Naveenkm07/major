import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

/// Unified API service for both Node.js backend and Python AI microservice.
class ApiService {
  final _storage = const FlutterSecureStorage();

  // ═══════════════════════════════════════════════════
  // Auth helpers
  // ═══════════════════════════════════════════════════

  Future<String?> _getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ═══════════════════════════════════════════════════
  // Generic HTTP methods (for Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${AppConstants.backendBaseUrl}$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: await _authHeaders()).timeout(const Duration(seconds: 30));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${AppConstants.backendBaseUrl}$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('${AppConstants.backendBaseUrl}$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));
    return jsonDecode(res.body);
  }

  // ═══════════════════════════════════════════════════
  // Auth endpoints (Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('/auth/login', {'email': email, 'password': password});
    if (data['success'] == true && data['token'] != null) {
      await saveToken(data['token']);
    }
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final data = await post('/auth/register', userData);
    if (data['success'] == true && data['token'] != null) {
      await saveToken(data['token']);
    }
    return data;
  }

  Future<Map<String, dynamic>> getProfile() async => get('/auth/me');

  Future<void> logout() async => clearToken();

  // ═══════════════════════════════════════════════════
  // Crops (Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> getCrops({String? season, String? search}) async {
    return get('/crops', query: {
      if (season != null) 'season': season,
      if (search != null) 'search': search,
    });
  }

  // ═══════════════════════════════════════════════════
  // Market Prices (Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> getMarketPrices({String? commodity, String? state}) async {
    return get('/market-prices', query: {
      if (commodity != null) 'commodity': commodity,
      if (state != null) 'state': state,
    });
  }

  // ═══════════════════════════════════════════════════
  // Government Schemes (Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> getSchemes({String? type}) async {
    return get('/schemes', query: {if (type != null) 'type': type});
  }

  // ═══════════════════════════════════════════════════
  // Loans (Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> getLoans() async => get('/loans');

  // ═══════════════════════════════════════════════════
  // Community (Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> getPosts({String? category}) async {
    return get('/community/posts', query: {if (category != null) 'category': category});
  }

  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    return post('/community/posts', postData);
  }

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    return put('/community/posts/$postId/like', {});
  }

  Future<Map<String, dynamic>> addComment(String postId, String text) async {
    return post('/community/posts/$postId/comments', {'text': text});
  }

  // ═══════════════════════════════════════════════════
  // AI Service: Pest Detection (Python FastAPI)
  // ═══════════════════════════════════════════════════

  /// Sends a crop image to POST /api/v1/detect_pest on the AI service.
  /// Returns JSON with pest label, confidence, treatment, and prevention.
  Future<Map<String, dynamic>> detectPest(File imageFile) async {
    final token = await _getToken();
    final uri = Uri.parse('${AppConstants.aiServiceUrl}/detect_pest');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Determine MIME type
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await streamedResponse.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  // ═══════════════════════════════════════════════════
  // AI Service: Chatbot (Python FastAPI)
  // ═══════════════════════════════════════════════════

  /// Sends a question to POST /api/v1/chat on the AI service.
  /// Returns JSON with answer, intent, suggestions.
  Future<Map<String, dynamic>> sendChatMessage(
    String question, {
    String language = 'en',
    Map<String, dynamic>? context,
  }) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('${AppConstants.aiServiceUrl}/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'question': question,
        'language': language,
        if (context != null) 'context': context,
      }),
    ).timeout(const Duration(seconds: 15));
    return jsonDecode(res.body);
  }
}
