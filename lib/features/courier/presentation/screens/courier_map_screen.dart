import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:le_livreur_pro/core/providers/maps_providers.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';
import 'package:le_livreur_pro/shared/widgets/maps_widget.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class CourierMapScreen extends ConsumerStatefulWidget {
  const CourierMapScreen({super.key});

  @override
  ConsumerState<CourierMapScreen> createState() => _CourierMapScreenState();
}

class _CourierMapScreenState extends ConsumerState<CourierMapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = <Marker>{};
  Set<Circle> _circles = <Circle>{};

  @override
  Widget build(BuildContext context) {
    final currentLocationAsync = ref.watch(currentLocationProvider);
    final deliveryZonesAsync = ref.watch(deliveryZonesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Carte de Livraison'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
          ),
        ],
      ),
      body: currentLocationAsync.when(
        data: (currentLocation) {
          if (currentLocation == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Position non disponible'.tr(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to get location again
                    },
                    child: Text('Réessayer'.tr()),
                  ),
                ],
              ),
            );
          }

          final center =
              LatLng(currentLocation.latitude, currentLocation.longitude);

          // Handle delivery zones
          deliveryZonesAsync.when(
            data: (zones) {
              _updateMarkersAndCircles(currentLocation, zones);
            },
            loading: () {
              // Loading state
            },
            error: (error, stack) {
              // Error state
            },
          );

          return MapsWidget(
            initialCenter: center,
            initialZoom: 13.0,
            markers: _markers,
            circles: _circles,
            showMyLocation: true,
            showMyLocationButton: true,
            showZoomControls: true,
            showCompass: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  void _updateMarkersAndCircles(Location currentLocation, List<LatLng> zones) {
    final markers = <Marker>{};
    final circles = <Circle>{};

    // Add current location marker
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(
          title: 'Ma Position'.tr(),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Add delivery zone markers and circles
    for (int i = 0; i < zones.length; i++) {
      final zone = zones[i];
      markers.add(
        Marker(
          markerId: MarkerId('zone_$i'),
          position: zone,
          infoWindow: InfoWindow(
            title: 'Zone de Livraison ${i + 1}'.tr(),
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      circles.add(
        Circle(
          circleId: CircleId('zone_circle_$i'),
          center: zone,
          radius: 2000, // 2km radius
          fillColor: AppTheme.primaryGreen.withOpacity(0.1),
          strokeColor: AppTheme.primaryGreen,
          strokeWidth: 2,
        ),
      );
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  void _centerOnCurrentLocation() {
    // Implementation would center the map on current location
  }
}
