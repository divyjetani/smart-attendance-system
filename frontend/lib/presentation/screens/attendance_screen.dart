import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_calendar.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String? _selectedSubjectId;
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user == null) return;
    if (user.role == 'student') {
      // Fetch subjects from subjectProvider
      final subjectsState = ref.read(subjectProvider);
      setState(() {
        _subjects = subjectsState.subjects.map((s) => s.id).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          if (user.role == 'student')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Subject'),
                items: _subjects.map((id) {
                  final subject = ref.read(subjectProvider).subjects.firstWhere((s) => s.id == id);
                  return DropdownMenuItem(value: id, child: Text(subject.name));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSubjectId = value);
                  if (value != null) {
                    ref.read(attendanceProvider.notifier).fetchAttendance(user.id, value);
                  }
                },
              ),
            ),
          Expanded(
            child: attendanceState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceState.attendanceList.isEmpty
                    ? const Center(child: Text('No attendance records'))
                    : AttendanceCalendar(attendanceList: attendanceState.attendanceList),
          ),
        ],
      ),
    );
  }
}