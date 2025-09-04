import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsWidget extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final bool showMyLocation;
  final bool showMyLocationButton;
  final bool showZoomControls;
  final bool showCompass;
  final bool showDeliveryZones;
  final Function(GoogleMapController)? onMapCreated;

  const MapsWidget({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13.0,
    this.markers = const {},
    this.polylines = const {},
    this.circles = const {},
    this.showMyLocation = true,
    this.showMyLocationButton = true,
    this.showZoomControls = true,
    this.showCompass = true,
    this.showDeliveryZones = false,
    this.onMapCreated,
  });

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialCenter,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers,
      polylines: widget.polylines,
      circles: widget.circles,
      myLocationEnabled: widget.showMyLocation,
      myLocationButtonEnabled: widget.showMyLocationButton,
      zoomControlsEnabled: widget.showZoomControls,
      compassEnabled: widget.showCompass,
      onMapCreated: (controller) {
        _mapController = controller;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
    );
  }
}
