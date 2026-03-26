import '../../domain/entities/subject.dart';

class SubjectModel extends SubjectEntity {
  SubjectModel({
    required super.id,
    required super.name,
    required super.semester,
    required super.professorId,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      name: json['name'],
      semester: json['semester'],
      professorId: json['professorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'semester': semester,
      'professorId': professorId,
    };
  }
}