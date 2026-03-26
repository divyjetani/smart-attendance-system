import '../repositories/student_repository.dart';

class ChangeDeviceUseCase {
  final StudentRepository repository;

  ChangeDeviceUseCase(this.repository);

  Future<void> call(String studentId, String newDeviceId) async {
    await repository.changeDevice(studentId, newDeviceId);
  }
}