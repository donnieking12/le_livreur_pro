import 'dart:async';
import 'dart:math' show sqrt, cos, sin, atan2;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';
import 'package:le_livreur_pro/core/config/app_config.dart';
import 'package:le_livreur_pro/core/utils/app_logger.dart';

class MapsService {
  static StreamController<Location>? _courierLocationController;
  static Timer? _locationTimer;

  // Get current device location (real implementation)
  static Future<Location?> getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Return demo location if permission denied
          return Location(
            latitude: 5.3600, // Abidjan coordinates
            longitude: -4.0083,
            timestamp: DateTime.now(),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Return demo location if permission denied forever
        return Location(
          latitude: 5.3600, // Abidjan coordinates
          longitude: -4.0083,
          timestamp: DateTime.now(),
        );
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Fallback to demo location if real location fails
      AppLogger.error('Error getting location, using fallback',
          tag: 'MapsService', error: e);
      return Location(
        latitude: 5.3600, // Abidjan coordinates
        longitude: -4.0083,
        timestamp: DateTime.now(),
      );
    }
  }

  // Get courier location stream with real-time simulation
  static Stream<Location> getCourierLocationStream() {
    _courierLocationController?.close();
    _courierLocationController = StreamController<Location>.broadcast();

    // Simulate courier movement for demo
    _simulateCourierMovement();

    return _courierLocationController!.stream;
  }

  // Simulate realistic courier movement patterns
  static void _simulateCourierMovement() {
    _locationTimer?.cancel();

    // Starting position (somewhere in Abidjan)
    double currentLat = 5.3600;
    double currentLng = -4.0083;
    double targetLat = 5.3800; // Moving towards delivery location
    double targetLng = -4.0200;

    const updateInterval = Duration(seconds: 3);
    const movementSpeed = 0.0001; // Degrees per update (realistic speed)

    _locationTimer = Timer.periodic(updateInterval, (timer) {
      // Calculate direction to target
      final double latDiff = targetLat - currentLat;
      final double lngDiff = targetLng - currentLng;
      final double distance = sqrt(latDiff * latDiff + lngDiff * lngDiff);

      if (distance < movementSpeed * 2) {
        // Reached target, set new random target within delivery area
        targetLat = 5.3600 +
            (DateTime.now().millisecondsSinceEpoch % 400 - 200) / 10000;
        targetLng = -4.0083 +
            (DateTime.now().millisecondsSinceEpoch % 400 - 200) / 10000;
      } else {
        // Move towards target
        currentLat += (latDiff / distance) * movementSpeed;
        currentLng += (lngDiff / distance) * movementSpeed;
      }

      // Add some realistic movement variation
      currentLat += (DateTime.now().millisecondsSinceEpoch % 20 - 10) / 100000;
      currentLng += (DateTime.now().millisecondsSinceEpoch % 20 - 10) / 100000;

      final location = Location(
        latitude: currentLat,
        longitude: currentLng,
        timestamp: DateTime.now(),
      );

      _courierLocationController?.add(location);
    });
  }

  // Stop courier location tracking
  static void stopCourierTracking() {
    _locationTimer?.cancel();
    _courierLocationController?.close();
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
