import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/hive_storage_service.dart';

class MarketPriceItem {
  final String commodity, market, district, state, unit;
  final double minPrice, maxPrice, modalPrice;
  final String? trend;

  MarketPriceItem({
    required this.commodity, required this.market, required this.district,
    required this.state, required this.unit, required this.minPrice,
    required this.maxPrice, required this.modalPrice, this.trend,
  });

  factory MarketPriceItem.fromJson(Map<String, dynamic> json) => MarketPriceItem(
        commodity: json['cropName'] ?? json['commodity'] ?? '',
        market: json['marketName'] ?? json['market'] ?? '',
        district: json['location']?['district'] ?? json['district'] ?? '',
        state: json['location']?['state'] ?? json['state'] ?? '',
        unit: json['unit'] ?? 'Quintal',
        minPrice: (json['minPrice'] ?? json['pricePerKg'] ?? 0).toDouble(),
        maxPrice: (json['maxPrice'] ?? json['pricePerKg'] ?? 0).toDouble(),
        modalPrice: (json['modalPrice'] ?? json['pricePerKg'] ?? 0).toDouble(),
        trend: json['trend'],
      );
}

class MarketProvider extends ChangeNotifier {
  final _api = ApiService();
  List<MarketPriceItem> _prices = [];
  bool _isLoading = false;

  List<MarketPriceItem> get prices => _prices;
  bool get isLoading => _isLoading;

  Future<void> fetchPrices({String? commodity, String? state}) async {
    // Try to load from cache first
    final cached = HiveStorageService.getCachedMarketPrices();
    if (cached != null && _prices.isEmpty) {
      _prices = cached.map((e) => MarketPriceItem.fromJson(Map<String, dynamic>.from(e))).toList();
      notifyListeners();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getMarketPrices(commodity: commodity, state: state);
      if (data['success'] == true) {
        _prices = (data['data'] as List).map((e) => MarketPriceItem.fromJson(e)).toList();
        // Save to cache
        await HiveStorageService.cacheMarketPrices(data['data']);
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
