import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.keyToken);
  }

  Future<void> setRole(String role) async {
    await _prefs.setString(AppConstants.keyRole, role);
  }

  String? getRole() {
    return _prefs.getString(AppConstants.keyRole);
  }

  Future<void> setUserId(String userId) async {
    await _prefs.setString(AppConstants.keyUserId, userId);
  }

  String? getUserId() {
    return _prefs.getString(AppConstants.keyUserId);
  }

  Future<void> setDeviceId(String deviceId) async {
    await _prefs.setString(AppConstants.keyDeviceId, deviceId);
  }

  String? getDeviceId() {
    return _prefs.getString(AppConstants.keyDeviceId);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}