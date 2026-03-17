import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<String?> getLocationHint() async {
    final permissionState = await Permission.locationWhenInUse.request();
    if (!permissionState.isGranted) return null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return 'Lat ${pos.latitude.toStringAsFixed(3)}, '
          'Lon ${pos.longitude.toStringAsFixed(3)}';
    } catch (_) {
      return null;
    }
  }
}
