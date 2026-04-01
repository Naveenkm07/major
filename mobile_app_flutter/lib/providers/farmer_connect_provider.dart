/// Farmer Connect Provider — manages nearby farmers data.
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NearbyFarmer {
  final String id;
  final String name;
  final String? cropType;
  final double lat;
  final double lng;
  final String? village;
  final String? phone;
  final List<String> resources;
  final double distance; // km

  NearbyFarmer({
    required this.id,
    required this.name,
    this.cropType,
    required this.lat,
    required this.lng,
    this.village,
    this.phone,
    this.resources = const [],
    this.distance = 0,
  });

  factory NearbyFarmer.fromJson(Map<String, dynamic> json) => NearbyFarmer(
        id: json['_id'] ?? '',
        name: json['name'] ?? 'Farmer',
        cropType: (json['cropTypes'] as List?)?.join(', '),
        lat: (json['location']?['coordinates']?[1] ?? json['lat'] ?? 0).toDouble(),
        lng: (json['location']?['coordinates']?[0] ?? json['lng'] ?? 0).toDouble(),
        village: json['village'],
        phone: json['phoneNumber'],
        resources: (json['resourcesAvailable'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        distance: (json['distance'] ?? 0).toDouble(),
      );
}

class FarmerConnectProvider extends ChangeNotifier {
  List<NearbyFarmer> _farmers = [];
  List<NearbyFarmer> get farmers => _farmers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double _searchRadius = 10.0; // km
  double get searchRadius => _searchRadius;

  void setRadius(double km) {
    _searchRadius = km;
    notifyListeners();
  }

  Future<void> loadNearbyFarmers(double lat, double lng) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().get(
        '/farmers/nearby?lat=$lat&lng=$lng&radius=${_searchRadius.toInt()}',
      );

      if (response != null && response['data'] != null) {
        _farmers = (response['data'] as List)
            .map((f) => NearbyFarmer.fromJson(f))
            .toList();
      } else {
        // Demo data for development
        _farmers = _getDemoFarmers(lat, lng);
      }
    } catch (e) {
      _error = e.toString();
      // Fall back to demo data
      _farmers = _getDemoFarmers(lat, lng);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<NearbyFarmer> _getDemoFarmers(double lat, double lng) => [
        NearbyFarmer(id: '1', name: 'Ramesh Kumar', cropType: 'Rice, Ragi', lat: lat + 0.01, lng: lng + 0.005, village: 'Hanur', resources: ['Seeds', 'Tractor'], distance: 1.2),
        NearbyFarmer(id: '2', name: 'Lakshmi Devi', cropType: 'Tomato, Beans', lat: lat - 0.008, lng: lng + 0.012, village: 'Magadi', resources: ['Sprayer', 'Organic Fertilizer'], distance: 2.5),
        NearbyFarmer(id: '3', name: 'Venkatesh G', cropType: 'Sugarcane', lat: lat + 0.015, lng: lng - 0.009, village: 'Mandya', resources: ['Harvester'], distance: 3.8),
        NearbyFarmer(id: '4', name: 'Savita Patil', cropType: 'Cotton, Groundnut', lat: lat - 0.02, lng: lng - 0.005, village: 'Dharwad', resources: ['Seeds', 'Plough'], distance: 5.1),
        NearbyFarmer(id: '5', name: 'Nagesh M', cropType: 'Rice, Wheat', lat: lat + 0.025, lng: lng + 0.018, village: 'Raichur', resources: ['Irrigation pipe'], distance: 7.3),
      ];
}
