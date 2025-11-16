import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // To navigate back to the login screen
import 'package:url_launcher/url_launcher.dart'; // To launch the document URLs
import 'timetable_screen.dart'; // Import the TimetableScreen

class AdminDashboard extends StatelessWidget {
  // Ensure const constructor is present
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard 🧑‍💻'),
        backgroundColor: Colors.red.shade700,
        actions: [
          // --- NEW: Timetable Navigation Button ---
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // Navigate to the TimetableScreen. 
              // We pass 'Admin' as the facultyName as a placeholder for the admin view.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TimeTableScreen(facultyName: 'Admin'),
                ),
              );
            },
            tooltip: 'View Timetable',
          ),
          // --- Existing Logout Button ---
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out the admin (if Firebase Auth was used for them)
              // Since you used hardcoded login for admin, we just navigate.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream to fetch all faculty data from Firestore
        stream: FirebaseFirestore.instance.collection('faculty').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No faculty registrations found.'));
          }

          // Separate the lists for visual clarity
          final pendingList = snapshot.data!.docs.where((doc) => doc['status'] == 'Pending').toList();
          final approvedList = snapshot.data!.docs.where((doc) => doc['status'] == 'Approved').toList();
          final rejectedList = snapshot.data!.docs.where((doc) => doc['status'] == 'Rejected').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Pending Approvals Section ---
                _buildSectionHeader('Pending Approvals (${pendingList.length}) ⏳', Colors.orange),
                if (pendingList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No new faculty registrations awaiting approval.'),
                  )
                else
                  ...pendingList.map((doc) => _buildFacultyCard(context, doc, isPending: true)).toList(),

                // Horizontal separator
                const Divider(height: 30, thickness: 2),

                // --- Approved Faculty Section ---
                _buildSectionHeader('Approved Faculty (${approvedList.length}) ✅', Colors.green.shade700),
                if (approvedList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No faculty have been approved yet.'),
                  )
                else
                  ...approvedList.map((doc) => _buildFacultyCard(context, doc, isPending: false)).toList(),

                // Horizontal separator
                const Divider(height: 30, thickness: 2),

                // --- Rejected Faculty Section ---
                _buildSectionHeader('Rejected Faculty (${rejectedList.length}) ❌', Colors.red.shade700),
                if (rejectedList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No faculty have been rejected.'),
                  )
                else
                  ...rejectedList.map((doc) => _buildFacultyCard(context, doc, isPending: false)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  // Helper widget to build individual faculty card
  Widget _buildFacultyCard(BuildContext context, DocumentSnapshot doc, {required bool isPending}) {
    final data = doc.data() as Map<String, dynamic>;
    final name = '${data['firstName']} ${data['lastName']}';
    final email = data['email'];
    final status = data['status'];
    final photoUrl = data['photoUrl'];
    final signatureUrl = data['signatureUrl'];
    final assignments = List<Map<String, dynamic>>.from(data['teachingAssignments'] ?? []);

    // Function to update faculty status
    void updateStatus(String newStatus) async {
      await FirebaseFirestore.instance.collection('faculty').doc(doc.id).update({'status': newStatus});
      
      // Optionally, you might want to send an email to the faculty member here
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name registration has been set to $newStatus.')),
        );
      }
    }
    
    // Function to launch URL
    void launchDocUrl(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch document URL.')),
          );
        }
      }
    }


    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Picture (Circle Avatar)
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(photoUrl),
                  onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.person, size: 30),
                  child: photoUrl == null || photoUrl.isEmpty ? const Icon(Icons.person, size: 30) : null,
                ),
                const SizedBox(width: 10),
                // Faculty Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(email, style: TextStyle(color: Colors.grey.shade600)),
                      Text('Status: $status', style: TextStyle(color: isPending ? Colors.orange : (status == 'Approved' ? Colors.green : Colors.red))),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 20),

            // Teaching Assignments
            const Text('Assignments:', style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: assignments.map((assignment) {
                  return Text(
                    '• ${assignment['subject']} (${assignment['class']} / ${assignment['division']})',
                    style: const TextStyle(fontSize: 13),
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 20),

            // Document Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.photo, size: 18),
                  label: const Text('View Photo'),
                  onPressed: () => launchDocUrl(photoUrl),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.insert_drive_file, size: 18),
                  label: const Text('View Signature/Doc'),
                  onPressed: () => launchDocUrl(signatureUrl),
                ),
              ],
            ),

            // Approval/Rejection Buttons (Only for Pending)
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => updateStatus('Rejected'),
                    child: const Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => updateStatus('Approved'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}