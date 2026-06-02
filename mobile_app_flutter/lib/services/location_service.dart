import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  /// Gets current GPS position and reverse-geocodes to district/state.
  /// Uses Nominatim (OpenStreetMap) HTTP API — works on ALL platforms including web.
  static Future<Map<String, String>?> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // 2. Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      // 3. Get GPS coordinates
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 15));

      final lat = position.latitude;
      final lon = position.longitude;

      // 4. Reverse geocode using Nominatim (works on web + mobile)
      final result = await _reverseGeocode(lat, lon);
      if (result != null) return result;

      // 5. Try native geocoding on mobile as fallback
      if (!kIsWeb) {
        final native = await _nativeReverseGeocode(lat, lon);
        if (native != null) return native;
      }

      // Last resort: return empty district (coords only)
      return {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'village': '',
        'district': '',
        'state': '',
      };
    } catch (e) {
      return null;
    }
  }

  /// Nominatim OpenStreetMap API — free, HTTP-based, works everywhere
  static Future<Map<String, String>?> _reverseGeocode(
      double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lon&format=json&addressdetails=1',
      );
      final res = await http.get(uri, headers: {
        'User-Agent': 'KrushikaDhara/1.0 (smart-farming)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final addr = (data['address'] as Map<String, dynamic>?) ?? {};

      // Nominatim has several fields — pick the most relevant ones
      final village = (addr['village'] ??
              addr['town'] ??
              addr['suburb'] ??
              addr['neighbourhood'] ??
              addr['municipality'] ??
              addr['hamlet'] ??
              '')
          .toString();

      final district = (addr['county'] ??
              addr['state_district'] ??
              addr['city_district'] ??
              addr['city'] ??
              addr['town'] ??
              '')
          .toString();

      final state = (addr['state'] ?? '').toString();

      return {
        'village': village,
        'district': district,
        'state': state,
        'lat': lat.toString(),
        'lon': lon.toString(),
      };
    } catch (_) {
      return null;
    }
  }

  /// Native geocoding (mobile only — geocoding package)
  static Future<Map<String, String>?> _nativeReverseGeocode(
      double lat, double lon) async {
    try {
      // Use geocoding package on mobile
      // ignore: depend_on_referenced_packages
      final geocoding = await _geocodingLookup(lat, lon);
      return geocoding;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>?> _geocodingLookup(
      double lat, double lon) async {
    try {
      // ignore: depend_on_referenced_packages
      final placemarks = await _getPlacemarks(lat, lon);
      return placemarks;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>?> _getPlacemarks(
      double lat, double lon) async {
    // Avoid importing geocoding directly to prevent web compile errors
    // This is intentionally left as null — Nominatim is the primary method
    return null;
  }
}
