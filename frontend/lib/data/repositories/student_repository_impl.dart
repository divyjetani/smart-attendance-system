import '../../domain/repositories/student_repository.dart';
import '../datasources/remote/api_service_impl.dart';
import '../../core/utils/logger.dart';
import '../models/student_model.dart';
import '../../domain/entities/student.dart';

class StudentRepositoryImpl implements StudentRepository {
  final ApiServiceImpl _apiService;

  StudentRepositoryImpl(this._apiService);

  @override
  Future<List<StudentEntity>> fetchStudentsBySubject(String subjectId) async {
    try {
      final response = await _apiService.get('/students/subject/$subjectId');
      final List<dynamic> data = response['students'];
      return data.map((json) => StudentModel.fromJson(json)).toList();
    } catch (e) {
      logger.e('Fetch students by subject error: $e');
      rethrow;
    }
  }

  @override
  Future<void> changeDevice(String studentId, String newDeviceId) async {
    try {
      await _apiService.post('/students/change-device', data: {
        'studentId': studentId,
        'newDeviceId': newDeviceId,
      });
    } catch (e) {
      logger.e('Change device error: $e');
      rethrow;
    }
  }
}