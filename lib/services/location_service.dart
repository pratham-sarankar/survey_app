import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> getLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await getLocationPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<double?> getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
      return false;
    }
  }
}