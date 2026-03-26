import '../repositories/student_repository.dart';
import '../entities/student.dart';

class FetchStudentsBySubjectUseCase {
  final StudentRepository repository;

  FetchStudentsBySubjectUseCase(this.repository);

  Future<List<StudentEntity>> call(String subjectId) async {
    return await repository.fetchStudentsBySubject(subjectId);
  }
}