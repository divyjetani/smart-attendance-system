import '../../domain/repositories/subject_repository.dart';
import '../datasources/remote/api_service_impl.dart';
import '../../core/utils/logger.dart';
import '../models/subject_model.dart';
import '../../domain/entities/subject.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final ApiServiceImpl _apiService;

  SubjectRepositoryImpl(this._apiService);

  @override
  Future<List<SubjectEntity>> fetchSubjectsBySemester(int semester, String studentId) async {
    try {
      final response = await _apiService.get('/subjects/semester/$semester/student/$studentId');
      final List<dynamic> data = response['subjects'];
      return data.map((json) => SubjectModel.fromJson(json)).toList();
    } catch (e) {
      logger.e('Fetch subjects by semester error: $e');
      rethrow;
    }
  }

  @override
  Future<List<SubjectEntity>> fetchSubjectsByProfessor(String professorId) async {
    try {
      final response = await _apiService.get('/subjects/professor/$professorId');
      final List<dynamic> data = response['subjects'];
      return data.map((json) => SubjectModel.fromJson(json)).toList();
    } catch (e) {
      logger.e('Fetch subjects by professor error: $e');
      rethrow;
    }
  }
}