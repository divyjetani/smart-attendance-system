import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/attendance.dart';

class AttendanceCalendar extends StatelessWidget {
  final List<AttendanceEntity> attendanceList;

  const AttendanceCalendar({super.key, required this.attendanceList});

  @override
  Widget build(BuildContext context) {
    // Group by month
    Map<DateTime, List<AttendanceEntity>> grouped = {};
    for (var a in attendanceList) {
      final month = DateTime(a.date.year, a.date.month);
      if (!grouped.containsKey(month)) grouped[month] = [];
      grouped[month]!.add(a);
    }

    final months = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        final entries = grouped[month]!;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, idx) {
                    final entry = entries[idx];
                    Color color;
                    if (entry.status == 'present') color = Colors.green;
                    else if (entry.status == 'absent') color = Colors.red;
                    else color = Colors.grey;
                    return Tooltip(
                      message: '${entry.formattedDate}: ${entry.status.toUpperCase()}',
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            entry.date.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}