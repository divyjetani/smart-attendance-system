import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password, String deviceId);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}