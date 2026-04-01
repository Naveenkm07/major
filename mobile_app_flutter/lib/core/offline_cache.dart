/// Offline-first cache layer using SharedPreferences.
/// Caches API responses as JSON strings so screens load instantly
/// even without internet, then refreshes in background.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCache {
  static const Duration defaultTtl = Duration(hours: 6);

  /// Save data to cache with a timestamp
  static Future<void> save(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString('cache_$key', jsonEncode(entry));
  }

  /// Read cached data (returns null if expired or missing)
  static Future<dynamic> read(String key, {Duration? ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cache_$key');
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(entry['timestamp']);
      final maxAge = ttl ?? defaultTtl;

      if (DateTime.now().difference(timestamp) > maxAge) {
        return null; // Expired
      }

      return entry['data'];
    } catch (_) {
      return null;
    }
  }

  /// Get cached data or fetch from network
  static Future<dynamic> getOrFetch(
    String key,
    Future<dynamic> Function() fetcher, {
    Duration? ttl,
  }) async {
    // Try cache first
    final cached = await read(key, ttl: ttl);
    if (cached != null) return cached;

    // Fetch from network
    try {
      final fresh = await fetcher();
      await save(key, fresh);
      return fresh;
    } catch (e) {
      // As last resort, return expired cache
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cache_$key');
      if (raw != null) {
        return jsonDecode(raw)['data'];
      }
      rethrow;
    }
  }

  /// Clear specific cached item
  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cache_$key');
  }

  /// Clear all cached data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
