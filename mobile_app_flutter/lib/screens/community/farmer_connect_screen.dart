/// Farmer Connect - Location Based Network
/// Shows nearby farmers on a Google Map and in a list.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/farmer_connect_provider.dart';
import '../../core/locale.dart';

class FarmerConnectScreen extends StatefulWidget {
  const FarmerConnectScreen({super.key});

  @override
  State<FarmerConnectScreen> createState() => _FarmerConnectScreenState();
}

class _FarmerConnectScreenState extends State<FarmerConnectScreen> {
  GoogleMapController? _mapController;
  bool _isMapView = true;
  
  // Default to Bangalore coords if location not available yet
  final LatLng _center = const LatLng(12.9716, 77.5946);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmerConnectProvider>(context, listen: false)
          .loadNearbyFarmers(_center.latitude, _center.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> _buildMarkers(List<NearbyFarmer> farmers) {
    return farmers.map((f) {
      return Marker(
        markerId: MarkerId(f.id),
        position: LatLng(f.lat, f.lng),
        infoWindow: InfoWindow(
          title: f.name,
          snippet: f.cropType ?? 'Farmer',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }).toSet()
      ..add(
        Marker(
          markerId: const MarkerId('me'),
          position: _center,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppLocale>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.tr('farmer_community')),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded),
            onPressed: () => setState(() => _isMapView = !_isMapView),
            tooltip: _isMapView ? 'Show List' : 'Show Map',
          ),
        ],
      ),
      body: Consumer<FarmerConnectProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          if (provider.error != null && provider.farmers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load farmers', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () => provider.loadNearbyFarmers(_center.latitude, _center.longitude),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.farmers.isEmpty) {
            return Center(
              child: Text(
                'No farmers found within ${provider.searchRadius} km',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return Column(
            children: [
              // ─── Radius Filter ────────────────────────
              Container(
                color: AppTheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: AppTheme.communityTeal, size: 20),
                    const SizedBox(width: 8),
                    const Text('Search Radius:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Slider(
                        value: provider.searchRadius,
                        min: 5,
                        max: 50,
                        divisions: 9,
                        activeColor: AppTheme.communityTeal,
                        label: '${provider.searchRadius.toInt()} km',
                        onChanged: (val) => provider.setRadius(val),
                        onChangeEnd: (_) => provider.loadNearbyFarmers(_center.latitude, _center.longitude),
                      ),
                    ),
                    Text('${provider.searchRadius.toInt()} km', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ─── Map / List Toggle ────────────────────
              Expanded(
                child: _isMapView
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
                        markers: _buildMarkers(provider.farmers),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.farmers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final f = provider.farmers[i];
                          return _FarmerCard(farmer: f);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _isMapView
          ? FloatingActionButton(
              backgroundColor: AppTheme.communityTeal,
              onPressed: () {
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_center, 12.0));
              },
              child: const Icon(Icons.my_location_rounded),
            )
          : null,
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final NearbyFarmer farmer;
  const _FarmerCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceVariant),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.communityTeal.withOpacity(0.1),
                child: const Icon(Icons.person_rounded, color: AppTheme.communityTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(farmer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '${farmer.distance.toStringAsFixed(1)} km away • ${farmer.village ?? 'Unknown location'}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryGreen),
                onPressed: () {
                  // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat feature coming soon')));
                },
              ),
            ],
          ),
          if (farmer.cropType != null && farmer.cropType!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.eco_rounded, size: 16, color: AppTheme.textHint),
                const SizedBox(width: 6),
                Text('Growing: ${farmer.cropType}', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
          if (farmer.resources.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: farmer.resources.map((r) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(r, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
