import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SemesterTile extends StatelessWidget {
  final int semester;

  const SemesterTile({super.key, required this.semester});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/subject-detail?semester=$semester');
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                'Semester $semester',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}