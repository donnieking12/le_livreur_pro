import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class Location {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Location({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Location.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'] as double,
        longitude = json['longitude'] as double,
        timestamp = DateTime.parse(json['timestamp'] as String);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      };
}

class RouteRequest {
  final LatLng origin;
  final LatLng destination;

  RouteRequest({
    required this.origin,
    required this.destination,
  });
}

class MapRoute {
  final List<LatLng> points;
  final double distance;
  final int durationSeconds;

  MapRoute({
    required this.points,
    required this.distance,
    required this.durationSeconds,
  });

  Polyline toPolyline({
    required Color color,
    required String id,
    int width = 5,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
    );
  }
}
