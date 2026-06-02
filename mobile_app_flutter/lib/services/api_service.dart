import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  // Notifications (Node.js backend)
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> getNotifications({bool unreadOnly = false}) async {
    return get('/notifications', query: {if (unreadOnly) 'unreadOnly': 'true'});
  }

  Future<Map<String, dynamic>> markNotificationRead(String id) async {
    return put('/notifications/$id/read', {});
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    return put('/notifications/read-all', {});
  }

  Future<Map<String, dynamic>> sendAdminNotification(Map<String, dynamic> data) async {
    return post('/notifications/send', data);
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

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'upload.$ext',
          contentType: MediaType.parse(mimeType),
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await streamedResponse.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  // ═══════════════════════════════════════════════════
  // AI Service: Chatbot (Grok API Integration)
  // ═══════════════════════════════════════════════════

  /// Sends a question to Grok AI.
  /// IMPORTANT: Replace 'YOUR_GROK_API_KEY' with your actual free API key from console.x.ai
  Future<Map<String, dynamic>> sendChatMessage(
    String question, {
    String language = 'en',
    Map<String, dynamic>? context,
  }) async {
    // Load API key from .env file securely
    final String grokApiKey = dotenv.env['GROK_API_KEY'] ?? '';
    final uri = Uri.parse('https://api.x.ai/v1/chat/completions');

    final systemPrompt = '''
You are KrushikaDhara, a helpful farming AI assistant in India.
Keep your answers concise, practical, and formatted in 2-3 short sentences.
Respond entirely in $language language.
''';

    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $grokApiKey',
        },
        body: jsonEncode({
          'model': 'grok-beta',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': question}
          ],
          'temperature': 0.3,
        }),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return {
          'answer': json['choices'][0]['message']['content'],
          'suggestions': [],
        };
      } else {
        // Fallback or error logging
        print('Grok API Error Code ${res.statusCode}: ${res.body}');
        
        // Give a more helpful message to the user if the key is missing or invalid
        String userError = 'Sorry, the AI service encountered an error. Code: ${res.statusCode}';
        if (res.statusCode == 401) {
          userError = 'AI Error: Invalid API Key. Please check your Grok API key in the .env file.';
        } else if (res.statusCode == 429) {
          userError = 'AI Error: Rate limit exceeded or out of credits.';
        } else if (res.statusCode == 404) {
          userError = 'AI Error: Model not found. Grok API might have updated their model names.';
        }
        
        return {
          'answer': userError,
          'suggestions': [],
        };
      }
    } catch (e) {
      print('Grok API Exception: $e');
      throw Exception('Failed to connect to AI');
    }
  }
}
