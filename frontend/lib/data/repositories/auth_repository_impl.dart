import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_service_impl.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiServiceImpl _apiService;
  final StorageService _storage;

  AuthRepositoryImpl(this._apiService, this._storage);

  @override
  Future<UserEntity> login(String email, String password, String deviceId) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
        'deviceId': deviceId,
      });
      final user = UserModel.fromJson(response['user']);
      await _storage.setToken(response['token']);
      await _storage.setRole(user.role);
      await _storage.setUserId(user.id);
      await _storage.setDeviceId(deviceId);
      return user;
    } catch (e) {
      logger.e('Login error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } finally {
      await _storage.clear();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = _storage.getToken();
    if (token == null) return null;
    try {
      final response = await _apiService.get('/auth/me');
      return UserModel.fromJson(response['user']);
    } catch (e) {
      logger.e('Get current user error: $e');
      return null;
    }
  }
}