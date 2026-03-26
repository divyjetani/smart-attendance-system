import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> fetchAttendance(String studentId, String subjectId);
  Future<void> markAttendance(String studentId, String subjectId, String qrCode);
}