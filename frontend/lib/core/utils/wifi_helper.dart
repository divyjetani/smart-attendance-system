import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import '../constants/app_constants.dart';

class WifiHelper {
  static Future<bool> isAllowedWifiConnected() async {
    try {
      String? ssid = await WifiInfo().getWifiName();
      if (ssid != null && ssid.contains(AppConstants.allowedWifiSSID)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}