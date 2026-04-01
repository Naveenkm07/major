/// Hive-based offline storage for queueing requests and caching large datasets
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  static const String _dbName = 'krushikadhara_offline';
  static const String _queueBoxName = 'sync_queue';
  static const String _cropBoxName = 'crop_calendar_cache';
  
  static late Box _queueBox;
  static late Box _cropBox;
  static late Box _marketBox;
  static late Box _schemeBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _queueBox = await Hive.openBox(_queueBoxName);
    _cropBox = await Hive.openBox(_cropBoxName);
    _marketBox = await Hive.openBox('market_cache');
    _schemeBox = await Hive.openBox('scheme_cache');
  }

  // ─── Offline Action Queue ─────────────────────────────
  
  /// Queues an API request (e.g. posting a message, updating profile)
  static Future<void> queueAction(String endpoint, String method, Map<String, dynamic> data) async {
    final action = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'endpoint': endpoint,
      'method': method,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _queueBox.add(action);
  }

  /// Gets all queued offline actions
  static List<Map<String, dynamic>> getQueuedActions() {
    return _queueBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Removes an action from the queue after successful sync
  static Future<void> removeAction(int index) async {
    await _queueBox.deleteAt(index);
  }

  /// Clears the entire queue
  static Future<void> clearQueue() async {
    await _queueBox.clear();
  }

  // ─── Heavy Data Caching (Crop Calendar) ───────────────
  
  static Future<void> cacheCropCalendar(String data) async {
    await _cropBox.put('calendar', data);
  }

  static String? getCachedCropCalendar() {
    return _cropBox.get('calendar');
  }

  // ─── Market & Schemes Caching ──────────────────────────
  
  static Future<void> cacheMarketPrices(List<dynamic> data) async {
    await _marketBox.put('prices', jsonEncode(data));
  }

  static List<dynamic>? getCachedMarketPrices() {
    final raw = _marketBox.get('prices');
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  static Future<void> cacheSchemes(List<dynamic> data) async {
    await _schemeBox.put('list', jsonEncode(data));
  }

  static List<dynamic>? getCachedSchemes() {
    final raw = _schemeBox.get('list');
    if (raw == null) return null;
    return jsonDecode(raw);
  }
}
