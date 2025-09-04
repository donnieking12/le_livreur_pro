import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';
import 'package:le_livreur_pro/core/services/maps_service.dart';

// Provider for current courier location
final courierLocationProvider = StreamProvider<Location>((ref) {
  return MapsService.getCourierLocationStream();
});

// Provider for current user location
final currentLocationProvider = FutureProvider<Location?>((ref) async {
  return await MapsService.getCurrentLocation();
});

// Provider for delivery zones
final deliveryZonesProvider = FutureProvider<List<LatLng>>((ref) async {
  return await MapsService.getDeliveryZones();
});

// Provider for route calculation
final routeProvider =
    FutureProvider.family<MapRoute, RouteRequest>((ref, request) async {
  return await MapsService.calculateRoute(
    origin: request.origin,
    destination: request.destination,
  );
});
