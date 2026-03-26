import '../../domain/repositories/attendance_repository.dart';
import '../datasources/remote/api_service_impl.dart';
import '../../core/utils/logger.dart';
import '../models/attendance_model.dart';
import '../../domain/entities/attendance.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final ApiServiceImpl _apiService;

  AttendanceRepositoryImpl(this._apiService);

  @override
  Future<List<AttendanceEntity>> fetchAttendance(String studentId, String subjectId) async {
    try {
      final response = await _apiService.get('/attendance/$studentId/$subjectId');
      final List<dynamic> data = response['attendance'];
      return data.map((json) => AttendanceModel.fromJson(json)).toList();
    } catch (e) {
      logger.e('Fetch attendance error: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAttendance(String studentId, String subjectId, String qrCode) async {
    try {
      await _apiService.post('/attendance/mark', data: {
        'studentId': studentId,
        'subjectId': subjectId,
        'qrCode': qrCode,
      });
    } catch (e) {
      logger.e('Mark attendance error: $e');
      rethrow;
    }
  }
}