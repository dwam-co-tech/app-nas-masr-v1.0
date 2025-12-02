import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final Location _location = Location();

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;

    try {
      return await _location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  double calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    final Distance distance = const Distance();
    return distance.as(
        LengthUnit.Meter, LatLng(startLat, startLng), LatLng(endLat, endLng));
  }
}
