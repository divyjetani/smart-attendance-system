import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';

class GeolocationHelper {
  static Future<bool> isWithinGeofence() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      AppConstants.geofenceLatitude,
      AppConstants.geofenceLongitude,
    );
    return distance <= AppConstants.geofenceRadius;
  }
}