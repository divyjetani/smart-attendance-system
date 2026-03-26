import '../repositories/subject_repository.dart';
import '../entities/subject.dart';

class FetchSubjectsBySemesterUseCase {
  final SubjectRepository repository;

  FetchSubjectsBySemesterUseCase(this.repository);

  Future<List<SubjectEntity>> call(int semester, String studentId) async {
    return await repository.fetchSubjectsBySemester(semester, studentId);
  }
}

class FetchSubjectsByProfessorUseCase {
  final SubjectRepository repository;

  FetchSubjectsByProfessorUseCase(this.repository);

  Future<List<SubjectEntity>> call(String professorId) async {
    return await repository.fetchSubjectsByProfessor(professorId);
  }
}