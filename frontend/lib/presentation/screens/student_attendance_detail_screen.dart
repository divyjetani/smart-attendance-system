import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_calendar.dart';
import '../../core/widgets/loading_overlay.dart';

class StudentAttendanceDetailScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String subjectId;

  const StudentAttendanceDetailScreen({super.key, required this.studentId, required this.subjectId});

  @override
  ConsumerState<StudentAttendanceDetailScreen> createState() => _StudentAttendanceDetailScreenState();
}

class _StudentAttendanceDetailScreenState extends ConsumerState<StudentAttendanceDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    await ref.read(attendanceProvider.notifier).fetchAttendance(widget.studentId, widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    return LoadingOverlay(
      isLoading: attendanceState.isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Student Attendance')),
        body: attendanceState.attendanceList.isEmpty
            ? const Center(child: Text('No attendance records'))
            : AttendanceCalendar(attendanceList: attendanceState.attendanceList),
      ),
    );
  }
}