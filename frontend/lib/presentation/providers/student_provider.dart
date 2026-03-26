import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student.dart';
import '../../domain/usecases/fetch_students_usecase.dart';
import '../../domain/usecases/change_device_usecase.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/datasources/remote/api_service_impl.dart';

final studentRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return StudentRepositoryImpl(apiService);
});

final fetchStudentsUseCaseProvider = Provider((ref) {
  final repo = ref.watch(studentRepositoryProvider);
  return FetchStudentsBySubjectUseCase(repo);
});

final changeDeviceUseCaseProvider = Provider((ref) {
  final repo = ref.watch(studentRepositoryProvider);
  return ChangeDeviceUseCase(repo);
});

class StudentState {
  final bool isLoading;
  final List<StudentEntity> students;
  final String? error;

  StudentState({
    required this.isLoading,
    required this.students,
    this.error,
  });

  factory StudentState.initial() => StudentState(isLoading: false, students: []);
  factory StudentState.loading() => StudentState(isLoading: true, students: []);
  factory StudentState.success(List<StudentEntity> list) => StudentState(isLoading: false, students: list);
  factory StudentState.error(String error) => StudentState(isLoading: false, students: [], error: error);
}

class StudentNotifier extends StateNotifier<StudentState> {
  final FetchStudentsBySubjectUseCase _fetchUseCase;
  final ChangeDeviceUseCase _changeDeviceUseCase;

  StudentNotifier(this._fetchUseCase, this._changeDeviceUseCase) : super(StudentState.initial());

  Future<void> fetchStudents(String subjectId) async {
    state = StudentState.loading();
    try {
      final list = await _fetchUseCase(subjectId);
      state = StudentState.success(list);
    } catch (e) {
      state = StudentState.error(e.toString());
    }
  }

  Future<void> changeDevice(String studentId, String newDeviceId) async {
    try {
      await _changeDeviceUseCase(studentId, newDeviceId);
      // Refresh list to show updated bound device
      // You'll need to pass subjectId again; for simplicity, we'll rely on caller to refresh
    } catch (e) {
      state = StudentState.error(e.toString());
    }
  }
}

final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((ref) {
  final fetchUseCase = ref.watch(fetchStudentsUseCaseProvider);
  final changeUseCase = ref.watch(changeDeviceUseCaseProvider);
  return StudentNotifier(fetchUseCase, changeUseCase);
});