import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/subject_card.dart';

class ProfessorSubjectsScreen extends ConsumerStatefulWidget {
  const ProfessorSubjectsScreen({super.key});

  @override
  ConsumerState<ProfessorSubjectsScreen> createState() => _ProfessorSubjectsScreenState();
}

class _ProfessorSubjectsScreenState extends ConsumerState<ProfessorSubjectsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final authState = ref.read(authProvider);
    final professorId = authState.user?.id;
    if (professorId != null) {
      await ref.read(subjectProvider.notifier).fetchSubjectsByProfessor(professorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectProvider);
    final subjects = subjectState.subjects;

    return Scaffold(
      appBar: AppBar(title: const Text('My Subjects'), automaticallyImplyLeading: false),
      body: subjectState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? const Center(child: Text('No subjects assigned'))
              : ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return SubjectCard(subject: subjects[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Take today's attendance - generate QR
          // Show dialog to select subject
          _showSubjectSelectionDialog();
        },
        child: const Icon(Icons.qr_code),
      ),
    );
  }

  void _showSubjectSelectionDialog() {
    final subjectState = ref.read(subjectProvider);
    final subjects = subjectState.subjects;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Subject'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(subjects[index].name),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/qr-generator/${subjects[index].id}');
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}