// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // For navigating back to login
import 'timetable_screen.dart'; // For future use if needed

class ProfileScreen extends StatelessWidget {
  final String firstName;
  final String? middleName; // CHANGE 1: Made nullable
  final String lastName;
  final String email;
  final String phoneNo;
  final List<String> assignments;

  const ProfileScreen({
    super.key,
    required this.firstName,
    this.middleName, // CHANGE 2: Optional, not required
    required this.lastName,
    required this.email,
    required this.phoneNo,
    required this.assignments,
  });

  // Handle logout and redirect to login
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Handle navigation to TimeTableScreen
  void _navigateToTimetable(BuildContext context, String fullName) {
    // Navigating to the TimeTableScreen.
    // NOTE: We don't need to await the result here, as the Home Screen handles
    // updating the schedule when the user returns.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimeTableScreen(
          facultyName: fullName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safely construct full name
    final middle = (middleName != null && middleName!.isNotEmpty) ? ' $middleName' : '';
    final fullName = '$firstName$middle $lastName';
    final displayFirstName = firstName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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

            _buildProfileDetail('First Name', firstName, Icons.badge),
            // CHANGE 3: Show middle name only if present
            if (middleName != null && middleName!.isNotEmpty)
              _buildProfileDetail('Middle Name', middleName!, Icons.badge_outlined),
            _buildProfileDetail('Last Name', lastName, Icons.badge),
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
                final parts = assignment.split(' - ');
                return _buildAssignmentTile(
                  className: parts.isNotEmpty ? parts[0] : 'N/A',
                  division: parts.length > 1 ? parts[1] : 'N/A',
                  subject: parts.length > 2 ? parts[2] : 'N/A',
                );
              }).toList(),
          ],
        ),
      ),

      // --- Bottom Navigation Bar (UPDATED) ---
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 1. Home / Back Button
              IconButton(
                icon: const Icon(Icons.home, color: Colors.indigo, size: 30),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Go Back to Home',
              ),
              
              // 2. NEW: Timetable Button (Calendar/Table Icon)
              IconButton(
                icon: const Icon(Icons.table_chart, color: Colors.blueGrey, size: 30),
                onPressed: () => _navigateToTimetable(context, fullName),
                tooltip: 'View Timetable',
              ),

              // 3. Logout Button
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red, size: 30),
                onPressed: () => _logout(context),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Build profile detail row
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

  // Helper: Build assignment card
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
}