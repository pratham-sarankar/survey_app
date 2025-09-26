import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/app_config.dart';

class LocationMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function(double lat, double lng)? onLocationTapped;

  const LocationMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.onLocationTapped,
  });

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarker();
  }

  @override
  void didUpdateWidget(LocationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || 
        oldWidget.longitude != widget.longitude) {
      _updateMarker();
      _moveCamera();
    }
  }

  void _updateMarker() {
    _markers = {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
        ),
      ),
    };
  }

  void _moveCamera() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.latitude, widget.longitude),
        ),
      );
    }
  }

  void _onMapTapped(LatLng position) {
    if (widget.onLocationTapped != null) {
      widget.onLocationTapped!(position.latitude, position.longitude);
    }
    
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          ),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: AppConfig.defaultZoom,
          ),
          markers: _markers,
          onTap: _onMapTapped,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }
}