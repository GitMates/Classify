// lib/screens/timetable_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pooja/screens/login_screen.dart'; 

class TimeTableScreen extends StatelessWidget {
  final String facultyName;
  
  const TimeTableScreen({super.key, required this.facultyName});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Navigate back to the LoginScreen and clear all routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Helper function to build the content for each day's tab
  Widget _buildDailySchedule(String day) {
    // ⚠️ NOTE: This is where you would fetch and display the actual timetable data
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$day Schedule',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const Divider(),
          const SizedBox(height: 10),
          // --- Dynamic Timetable Display Area ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No periods assigned for this day yet.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                ),
                SizedBox(height: 15),
                // Placeholder for actual classes (example structure)
                ListTile(
                  leading: Icon(Icons.schedule, color: Colors.green),
                  title: Text('09:00 AM - 10:00 AM'),
                  subtitle: Text('Course: CS202 - Data Structures\nRoom: A-301'),
                ),
                ListTile(
                  leading: Icon(Icons.schedule, color: Colors.orange),
                  title: Text('11:00 AM - 12:00 PM'),
                  subtitle: Text('Course: MA101 - Calculus\nRoom: B-105'),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the days for the tabs
    const List<String> days = [
      'Mon', 
      'Tue', 
      'Wed', 
      'Thu', 
      'Fri', 
      'Sat'
    ];

    return DefaultTabController(
      length: days.length, // Number of tabs (6 days)
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, ${facultyName.split(' ')[0]}'), // Display only first name for brevity
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
          // Tab Bar positioned at the bottom of the AppBar
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: days.map((day) => Tab(text: day)).toList(),
          ),
        ),
        body: TabBarView(
          children: days.map((day) {
            return _buildDailySchedule(day);
          }).toList(),
        ),
      ),
    );
  }
}