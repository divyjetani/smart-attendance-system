import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../providers/subject_provider.dart';
import '../widgets/attendance_calendar.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../domain/entities/subject.dart';
import '../../core/utils/logger.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String? semesterParam;

  const SubjectDetailScreen({super.key, required this.subjectId, this.semesterParam});

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  SubjectEntity? subject;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubject();
  }

  Future<void> _loadSubject() async {
    setState(() => isLoading = true);
    // Fetch subject details from subjects list
    final subjectsState = ref.read(subjectProvider);
    final allSubjects = subjectsState.subjects;
    subject = allSubjects.firstWhere((s) => s.id == widget.subjectId, orElse: () => null);
    if (subject != null) {
      final authState = ref.read(authProvider);
      final studentId = authState.user?.id;
      if (studentId != null) {
        await ref.read(attendanceProvider.notifier).fetchAttendance(studentId, widget.subjectId);
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    final loading = isLoading || attendanceState.isLoading;
    return LoadingOverlay(
      isLoading: loading,
      child: Scaffold(
        appBar: AppBar(title: Text(subject?.name ?? 'Subject Details')),
        body: subject == null
            ? const Center(child: Text('Subject not found'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subject: ${subject!.name}', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Semester: ${subject!.semester}'),
                            Text('Professor ID: ${subject!.professorId}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Attendance Calendar', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AttendanceCalendar(attendanceList: attendanceState.attendanceList),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}