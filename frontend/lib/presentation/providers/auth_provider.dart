import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/fetch_subjects_usecase.dart' as subject_uc;
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/subject_repository_impl.dart';
import '../../data/datasources/remote/api_service_impl.dart';
import '../../core/services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final apiServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiServiceImpl(storage);
});

final authRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(apiService, storage);
});

final loginUseCaseProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

final fetchSubjectsByProfessorUseCaseProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final repo = SubjectRepositoryImpl(apiService);
  return subject_uc.FetchSubjectsByProfessorUseCase(repo);
});

final fetchSubjectsBySemesterUseCaseProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final repo = SubjectRepositoryImpl(apiService);
  return subject_uc.FetchSubjectsBySemesterUseCase(repo);
});

enum AuthStateStatus { unauthenticated, authenticated, loading }

class AuthState {
  final AuthStateStatus status;
  final UserEntity? user;
  final String? error;

  AuthState({required this.status, this.user, this.error});

  factory AuthState.initial() => AuthState(status: AuthStateStatus.unauthenticated);
  factory AuthState.loading() => AuthState(status: AuthStateStatus.loading);
  factory AuthState.authenticated(UserEntity user) => AuthState(status: AuthStateStatus.authenticated, user: user);
  factory AuthState.error(String error) => AuthState(status: AuthStateStatus.unauthenticated, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final StorageService _storage;

  AuthNotifier(this._loginUseCase, this._storage) : super(AuthState.initial());

  Future<void> login(String email, String password, String deviceId) async {
    state = AuthState.loading();
    try {
      final user = await _loginUseCase(email, password, deviceId);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    state = AuthState.initial();
  }

  Future<void> checkAuth() async {
    final token = _storage.getToken();
    if (token != null) {
      // In real app, you would fetch user from API using token
      // For mock, we can create a dummy user
      final role = _storage.getRole();
      final userId = _storage.getUserId();
      if (role != null && userId != null) {
        state = AuthState.authenticated(UserEntity(
          id: userId,
          name: '',
          email: '',
          role: role,
        ));
        return;
      }
    }
    state = AuthState.initial();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final storage = ref.watch(storageServiceProvider);
  final notifier = AuthNotifier(loginUseCase, storage);
  notifier.checkAuth();
  return notifier;
});