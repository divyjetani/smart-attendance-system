import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_provider.dart';
import '../../domain/entities/student.dart';

class ProfessorStudentsScreen extends ConsumerStatefulWidget {
  final String subjectId;

  const ProfessorStudentsScreen({super.key, required this.subjectId});

  @override
  ConsumerState<ProfessorStudentsScreen> createState() => _ProfessorStudentsScreenState();
}

class _ProfessorStudentsScreenState extends ConsumerState<ProfessorStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    await ref.read(studentProvider.notifier).fetchStudents(widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final students = studentState.students;
    final filteredStudents = students.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.enrollmentNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      // Filter by date would require fetching attendance data per student; we'll skip for brevity
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name or enrollment',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: studentState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return ListTile(
                            title: Text(student.name),
                            subtitle: Text('Enrollment: ${student.enrollmentNumber}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.device_reset),
                              onPressed: () => _showChangeDeviceDialog(student),
                              tooltip: 'Reset Device',
                            ),
                            onTap: () {
                              context.push('/student-attendance-detail/${student.id}/${widget.subjectId}');
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/upload-attendance');
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload XLS'),
      ),
    );
  }

  void _showChangeDeviceDialog(StudentEntity student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Device'),
          content: Text('Reset device binding for ${student.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // In a real app, you'd ask for new device ID or just clear binding
                // For simplicity, we'll send an empty string to clear
                await ref.read(studentProvider.notifier).changeDevice(student.id, '');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Device reset successfully')),
                  );
                  _loadStudents(); // refresh list
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}