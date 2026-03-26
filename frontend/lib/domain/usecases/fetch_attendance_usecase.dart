import '../repositories/attendance_repository.dart';
import '../entities/attendance.dart';

class FetchAttendanceUseCase {
  final AttendanceRepository repository;

  FetchAttendanceUseCase(this.repository);

  Future<List<AttendanceEntity>> call(String studentId, String subjectId) async {
    return await repository.fetchAttendance(studentId, subjectId);
  }
}