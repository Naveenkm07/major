import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommunityProvider extends ChangeNotifier {
  final _api = ApiService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts({String? category}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getPosts(category: category);
      if (data['success'] == true) {
        _posts = List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPost(String content) async {
    try {
      await _api.createPost({'content': content, 'category': 'general'});
      await fetchPosts();
    } catch (_) {}
  }

  Future<void> toggleLike(String postId) async {
    try {
      await _api.toggleLike(postId);
      await fetchPosts();
    } catch (_) {}
  }
}
