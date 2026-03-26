import '../../domain/entities/attendance.dart';

class AttendanceModel extends AttendanceEntity {
  AttendanceModel({
    required super.id,
    required super.studentId,
    required super.subjectId,
    required super.date,
    required super.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      studentId: json['studentId'],
      subjectId: json['subjectId'],
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'subjectId': subjectId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}