import '../entities/subject.dart';

abstract class SubjectRepository {
  Future<List<SubjectEntity>> fetchSubjectsBySemester(int semester, String studentId);
  Future<List<SubjectEntity>> fetchSubjectsByProfessor(String professorId);
}