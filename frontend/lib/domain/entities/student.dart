class StudentEntity {
  final String id;
  final String name;
  final String enrollmentNumber;
  final String? boundDeviceId; // null if not bound

  StudentEntity({
    required this.id,
    required this.name,
    required this.enrollmentNumber,
    this.boundDeviceId,
  });
}