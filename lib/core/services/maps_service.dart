import 'dart:async';
import 'dart:math' show sqrt, cos, sin, atan2;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';

class MapsService {
  // Get current location (mock implementation)
  static Future<Location?> getCurrentLocation() async {
    // In a real implementation, this would use location services
    // For now, return a mock location
    return Location(
      latitude: 5.3600, // Abidjan coordinates
      longitude: -4.0083,
      timestamp: DateTime.now(),
    );
  }

  // Get courier location stream (mock implementation)
  static Stream<Location> getCourierLocationStream() async* {
    // In a real implementation, this would listen to real-time courier location updates
    // For now, yield mock locations periodically
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      yield Location(
        latitude:
            5.3600 + (DateTime.now().millisecondsSinceEpoch % 1000) / 10000,
        longitude:
            -4.0083 + (DateTime.now().millisecondsSinceEpoch % 1000) / 10000,
        timestamp: DateTime.now(),
      );
    }
  }

  // Get delivery zones (mock implementation)
  static Future<List<LatLng>> getDeliveryZones() async {
    // In a real implementation, this would fetch delivery zones from the backend
    // For now, return mock zones around Abidjan
    return [
      const LatLng(5.3600, -4.0083), // Abidjan center
      const LatLng(5.3800, -4.0200), // Plateau
      const LatLng(5.3500, -3.9900), // Cocody
      const LatLng(5.3300, -4.0100), // Treichville
      const LatLng(5.3700, -3.9700), // Bingerville
    ];
  }

  // Calculate route between two points (mock implementation)
  static Future<MapRoute> calculateRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // In a real implementation, this would use a routing API like Google Directions
    // For now, return a simple straight line route
    return MapRoute(
      points: [origin, destination],
      distance: _calculateDistance(origin, destination),
      durationSeconds: (_calculateDistance(origin, destination) * 120)
          .toInt(), // Rough estimate: 2 min per km
    );
  }

  // Helper method to calculate distance between two points
  static double _calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371; // Earth's radius in km

    final double lat1 = _degreesToRadians(from.latitude);
    final double lon1 = _degreesToRadians(from.longitude);
    final double lat2 = _degreesToRadians(to.latitude);
    final double lon2 = _degreesToRadians(to.longitude);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * 3.14159265358979323846264338327950288 / 180;
  }
}
