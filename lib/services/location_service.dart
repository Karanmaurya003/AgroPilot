// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {
  // Method to request permission and get current coordinates
  Future<Position> getCurrentLocation() async {
    LocationPermission permission;

    // We have removed the isLocationServiceEnabled() check
    // as getCurrentPosition() will throw an error if services are disabled,
    // which our try-catch block will handle.

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Permissions granted, return the position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}