import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/fetch_attendance_usecase.dart';
import '../../domain/usecases/mark_attendance_usecase.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/datasources/remote/api_service_impl.dart';
import '../../domain/entities/attendance.dart';

final attendanceRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AttendanceRepositoryImpl(apiService);
});

final fetchAttendanceUseCaseProvider = Provider((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return FetchAttendanceUseCase(repo);
});

final markAttendanceUseCaseProvider = Provider((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return MarkAttendanceUseCase(repo);
});

class AttendanceState {
  final bool isLoading;
  final List<AttendanceEntity> attendanceList;
  final String? error;

  AttendanceState({
    required this.isLoading,
    required this.attendanceList,
    this.error,
  });

  factory AttendanceState.initial() => AttendanceState(isLoading: false, attendanceList: []);
  factory AttendanceState.loading() => AttendanceState(isLoading: true, attendanceList: []);
  factory AttendanceState.success(List<AttendanceEntity> list) => AttendanceState(isLoading: false, attendanceList: list);
  factory AttendanceState.error(String error) => AttendanceState(isLoading: false, attendanceList: [], error: error);
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final FetchAttendanceUseCase _fetchUseCase;
  final MarkAttendanceUseCase _markUseCase;

  AttendanceNotifier(this._fetchUseCase, this._markUseCase) : super(AttendanceState.initial());

  Future<void> fetchAttendance(String studentId, String subjectId) async {
    state = AttendanceState.loading();
    try {
      final list = await _fetchUseCase(studentId, subjectId);
      state = AttendanceState.success(list);
    } catch (e) {
      state = AttendanceState.error(e.toString());
    }
  }

  Future<void> markAttendance(String studentId, String subjectId, String qrCode) async {
    // You can also show loading overlay inside the screen
    try {
      await _markUseCase(studentId, subjectId, qrCode);
      // Refresh attendance after marking
      await fetchAttendance(studentId, subjectId);
    } catch (e) {
      // Propagate error to UI
      state = AttendanceState.error(e.toString());
    }
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final fetchUseCase = ref.watch(fetchAttendanceUseCaseProvider);
  final markUseCase = ref.watch(markAttendanceUseCaseProvider);
  return AttendanceNotifier(fetchUseCase, markUseCase);
});