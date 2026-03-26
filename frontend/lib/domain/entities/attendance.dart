import 'package:intl/intl.dart';

class AttendanceEntity {
  final String id;
  final String studentId;
  final String subjectId;
  final DateTime date;
  final String status; // 'present', 'absent', 'holiday'

  AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
}