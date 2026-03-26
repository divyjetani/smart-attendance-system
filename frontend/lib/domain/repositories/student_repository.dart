import '../entities/student.dart';

abstract class StudentRepository {
  Future<List<StudentEntity>> fetchStudentsBySubject(String subjectId);
  Future<void> changeDevice(String studentId, String newDeviceId);
}