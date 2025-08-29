import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsService {
  static const String _googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Default map configuration
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(5.3600, -4.0083), // Abidjan, Côte d'Ivoire
    zoom: 12.0,
  );

  /// Get Google Maps API key
  static String get apiKey => _googleMapsApiKey;

  /// Get default camera position
  static CameraPosition get defaultPosition => _defaultPosition;

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      if (await requestLocationPermission()) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Calculate distance between two points
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Get route between two points
  static Future<List<LatLng>> getRoute(
      LatLng origin, LatLng destination) async {
    // TODO: Implement Google Directions API integration
    // For now, return a straight line
    return [origin, destination];
  }

  /// Get estimated travel time
  static Future<Duration> getEstimatedTravelTime(
    LatLng origin,
    LatLng destination,
    String mode, // 'driving', 'walking', 'bicycling'
  ) async {
    // TODO: Implement Google Directions API for travel time
    final distance = calculateDistance(origin, destination);
    final averageSpeed = mode == 'driving' ? 30.0 : 5.0; // km/h
    final timeInHours = distance / 1000 / averageSpeed;
    return Duration(minutes: (timeInHours * 60).round());
  }

  /// Create custom map markers
  static BitmapDescriptor createCustomMarker({
    required String title,
    required Color color,
    IconData? icon,
  }) {
    // TODO: Implement custom marker creation
    return BitmapDescriptor.defaultMarkerWithHue(
      color == Colors.red
          ? BitmapDescriptor.hueRed
          : color == Colors.green
              ? BitmapDescriptor.hueGreen
              : color == Colors.blue
                  ? BitmapDescriptor.hueBlue
                  : BitmapDescriptor.hueOrange,
    );
  }

  /// Get delivery zones
  static List<Map<String, dynamic>> getDeliveryZones() {
    return [
      {
        'name': 'Abidjan Centre',
        'center': const LatLng(5.3600, -4.0083),
        'radius': 5000, // 5km
        'basePrice': 500.0,
        'color': Colors.green,
      },
      {
        'name': 'Cocody',
        'center': const LatLng(5.3500, -3.9900),
        'radius': 3000, // 3km
        'basePrice': 400.0,
        'color': Colors.blue,
      },
      {
        'name': 'Plateau',
        'center': const LatLng(5.3200, -4.0200),
        'radius': 4000, // 4km
        'basePrice': 450.0,
        'color': Colors.orange,
      },
      {
        'name': 'Yopougon',
        'center': const LatLng(5.3800, -4.0500),
        'radius': 3500, // 3.5km
        'basePrice': 420.0,
        'color': Colors.purple,
      },
    ];
  }

  /// Check if location is within delivery zone
  static bool isWithinDeliveryZone(
      LatLng location, LatLng zoneCenter, double radius) {
    final distance = calculateDistance(location, zoneCenter);
    return distance <= radius;
  }

  /// Get nearest delivery zone
  static Map<String, dynamic>? getNearestDeliveryZone(LatLng location) {
    final zones = getDeliveryZones();
    Map<String, dynamic>? nearestZone;
    double minDistance = double.infinity;

    for (final zone in zones) {
      final distance = calculateDistance(location, zone['center']);
      if (distance < minDistance) {
        minDistance = distance;
        nearestZone = zone;
      }
    }

    return nearestZone;
  }

  /// Calculate delivery fee based on distance and zone
  static double calculateDeliveryFee(LatLng pickup, LatLng delivery) {
    final distance = calculateDistance(pickup, delivery);
    final nearestZone = getNearestDeliveryZone(pickup);

    if (nearestZone != null) {
      final basePrice = nearestZone['basePrice'] as double;
      final additionalKm = (distance - 1000) / 1000; // Additional km beyond 1km

      if (additionalKm > 0) {
        return basePrice + (additionalKm * 100); // 100 XOF per additional km
      }

      return basePrice;
    }

    // Default pricing if no zone found
    return 500 + (distance / 1000 * 100);
  }

  /// Get real-time traffic information
  static Future<Map<String, dynamic>> getTrafficInfo(LatLng location) async {
    // TODO: Implement Google Traffic API integration
    return {
      'congestion_level': 'low',
      'estimated_delay': const Duration(minutes: 5),
      'route_alternatives': 2,
    };
  }

  /// Track courier location in real-time
  static Stream<Position> trackCourierLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Get address from coordinates (reverse geocoding)
  static Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      // TODO: Implement reverse geocoding with Google Geocoding API
      // For now, return a placeholder
      return 'Address not available - implement Google Geocoding API';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  /// Get coordinates from address (geocoding)
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // TODO: Implement geocoding with Google Geocoding API
      // For now, return a placeholder
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }
}
