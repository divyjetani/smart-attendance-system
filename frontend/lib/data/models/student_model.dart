import '../../domain/entities/student.dart';

class StudentModel extends StudentEntity {
  StudentModel({
    required super.id,
    required super.name,
    required super.enrollmentNumber,
    required super.boundDeviceId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      enrollmentNumber: json['enrollmentNumber'],
      boundDeviceId: json['boundDeviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enrollmentNumber': enrollmentNumber,
      'boundDeviceId': boundDeviceId,
    };
  }
}