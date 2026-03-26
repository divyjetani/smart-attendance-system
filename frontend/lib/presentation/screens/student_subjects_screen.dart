import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/semester_tile.dart';

class StudentSubjectsScreen extends ConsumerStatefulWidget {
  const StudentSubjectsScreen({super.key});

  @override
  ConsumerState<StudentSubjectsScreen> createState() => _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends ConsumerState<StudentSubjectsScreen> {
  final List<int> semesters = List.generate(8, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Semester'), automaticallyImplyLeading: false),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: semesters.length,
        itemBuilder: (context, index) {
          return SemesterTile(semester: semesters[index]);
        },
      ),
    );
  }
}