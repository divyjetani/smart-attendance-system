import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/subject.dart';

class SubjectCard extends StatelessWidget {
  final SubjectEntity subject;

  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(subject.name),
        subtitle: Text('Semester ${subject.semester}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/professor-students/${subject.id}');
        },
      ),
    );
  }
}