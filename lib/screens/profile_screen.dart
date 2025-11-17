import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'notes_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String phoneNo;
  final List<dynamic> assignments;
  final VoidCallback onNavigateHome;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNo,
    required this.assignments,
    required this.onNavigateHome,
    required this.onLogout,
  });

  void _navigateToNotes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotesScreen(),
      ),
    );
  }

  Widget _buildProfileDetail(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildAssignmentTile({
    required String className,
    required String division,
    required String subject,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject: $subject',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Class: $className | Division: $division',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final middle = (middleName != null && middleName!.isNotEmpty) ? ' $middleName' : '';
    final fullName = '$firstName$middle $lastName';
    final displayFirstName = firstName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            onPressed: () => _navigateToNotes(context),
            tooltip: 'My Notes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Profile Header ---
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, $displayFirstName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 30, thickness: 1),

            // --- Contact Details ---
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildProfileDetail('Full Name', fullName, Icons.badge),
            _buildProfileDetail('Email ID', email, Icons.email),
            _buildProfileDetail('Phone Number', phoneNo, Icons.phone),

            const Divider(height: 30, thickness: 1),

            // --- Teaching Assignments ---
            const Text(
              'Teaching Assignments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (assignments.isEmpty)
              const Text(
                'No assignments currently listed.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              )
            else
              ...assignments.map((assignment) {
                if (assignment is Map<String, dynamic>) {
                  return _buildAssignmentTile(
                    className: assignment['class'] ?? 'N/A',
                    division: assignment['division'] ?? 'N/A',
                    subject: assignment['subject'] ?? 'N/A',
                  );
                } else {
                  final parts = assignment.toString().split(' - ');
                  return _buildAssignmentTile(
                    className: parts.isNotEmpty ? parts[0] : 'N/A',
                    division: parts.length > 1 ? parts[1] : 'N/A',
                    subject: parts.length > 2 ? parts[2] : 'N/A',
                  );
                }
              }).toList(),

            // --- Logout Button (centered at bottom) ---
            const SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, size: 40, color: Colors.red),
                    onPressed: onLogout,
                    tooltip: 'Logout',
                  ),
                  const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}