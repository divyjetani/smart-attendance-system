import '../repositories/attendance_repository.dart';

class MarkAttendanceUseCase {
  final AttendanceRepository repository;

  MarkAttendanceUseCase(this.repository);

  Future<void> call(String studentId, String subjectId, String qrCode) async {
    await repository.markAttendance(studentId, subjectId, qrCode);
  }
}