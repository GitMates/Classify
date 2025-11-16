import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import Assignment model

class NotifyScreen extends StatelessWidget {
  final Assignment? upcomingAssignment;

  const NotifyScreen({
    super.key,
    required this.upcomingAssignment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Reminders'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: upcomingAssignment == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, size: 60, color: Colors.green.shade400),
                    const SizedBox(height: 20),
                    const Text(
                      'All Clear!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No classes starting in the next 5 minutes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                )
              : _buildReminderCard(context, upcomingAssignment!),
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Assignment assignment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.indigo, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alarm_on, color: Colors.indigo.shade700, size: 30),
              const SizedBox(width: 10),
              Text(
                'UPCOMING CLASS REMINDER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1.5),
          _buildInfoRow('Subject:', assignment.subject, Icons.book),
          _buildInfoRow('Time:', assignment.time, Icons.schedule),
          _buildInfoRow('Day:', assignment.day, Icons.calendar_today),
          _buildInfoRow('Section:', assignment.section, Icons.group),
          _buildInfoRow('Faculty Code:', assignment.facultyCode, Icons.person_pin),
          const SizedBox(height: 15),
          Text(
            'Message: Please report to your assigned room for ${assignment.subject} starting in under 5 minutes.',
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String detail, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo.shade400),
          const SizedBox(width: 8),
          Text(
            '$title ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              detail,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}