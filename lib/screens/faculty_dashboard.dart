// lib/screens/faculty_dashboard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 💡 REQUIRED FIX: Import the intl package for DateFormat
import 'package:firebase_auth/firebase_auth.dart';
// Note: You should only import what's needed. Since FirebaseAuth isn't used here, 
// you can remove it, but I'll leave it in for completeness if you use it later.

class FacultyDashboardScreen extends StatelessWidget {
  final String facultyName;
  final Map<String, List<Map<String, String>>> selectedSchedule;

  const FacultyDashboardScreen({
    super.key,
    required this.facultyName,
    required this.selectedSchedule,
  });

  // Helper to get the current day's name (e.g., "Mon", "Tue")
  String _getCurrentDayAbbreviation() {
    // Note: DateFormat('EEE') returns 'Sat' for Saturday, which matches your timetable keys.
    return DateFormat('EEE').format(DateTime.now());
  }

  // Function to build a schedule card
  Widget _buildScheduleCard(String time, String subject, String facultyCode, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          // Uses the color for the left border for emphasis
          border: Border(left: BorderSide(color: color, width: 5)),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time: $time',
                  style: TextStyle(fontSize: 16, color: color),
                ),
                Text(
                  'Code: ${facultyCode.isEmpty ? 'N/A' : facultyCode}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current day abbreviation to display today's schedule first
    final currentDayAbbr = _getCurrentDayAbbreviation();
    final dailySchedule = selectedSchedule.containsKey(currentDayAbbr)
        ? selectedSchedule[currentDayAbbr]!
        : <Map<String, String>>[];

    // Define colors for the cards
    const List<Color> cardColors = [
      Colors.indigo,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${facultyName.split(' ')[0]}\'s Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Current Day Highlight ---
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      // This line is now correct, assuming 'package:intl/intl.dart' is imported.
                      'Today is ${DateFormat('EEEE, MMM d, yyyy').format(DateTime.now())}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Your Schedule for ${currentDayAbbr.toUpperCase()}',
                      style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),

            // --- Today's Periods ---
            Text(
              dailySchedule.isEmpty ? 'You have no scheduled periods today.' : 'Today\'s Classes:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            if (dailySchedule.isNotEmpty)
              ...List.generate(dailySchedule.length, (index) {
                final period = dailySchedule[index];
                return _buildScheduleCard(
                  period['time']!,
                  period['subject']!,
                  period['faculty']!,
                  cardColors[index % cardColors.length], // Cycle through colors
                );
              }),

            const SizedBox(height: 30),
            const Divider(),

            // --- Full Weekly Schedule Overview ---
            const Text(
              'Full Selected Weekly Schedule',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // Iterate through the days Mon-Sat
            ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
              final schedule = selectedSchedule[day];
              if (schedule == null || schedule.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$day: No classes selected.',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                );
              }

              return ExpansionTile(
                title: Text(
                  '$day (${schedule.length} Classes)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: schedule.map((period) {
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 30, right: 16),
                    leading: const Icon(Icons.access_time, color: Colors.blueGrey),
                    title: Text('${period['time']} - ${period['subject']}'),
                    subtitle: Text('Faculty Code: ${period['faculty']!.isEmpty ? 'N/A' : period['faculty']}'),
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}