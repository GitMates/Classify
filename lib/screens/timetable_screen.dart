import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For diagnostic logging
import 'package:pooja/screens/home_screen.dart';// Import the new HomeScreen

// --- Global Firebase Configuration (Simulated for Canvas) ---
// Note: These must be consistent with home_screen.dart
const String __app_id = 'timetable-app-v1';
const String __initial_auth_token = '';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

// --- 1. Timetable Data Structure ---
// NOTE: This data is critical for reconstructing the full schedule.
const Map<String, Map<String, dynamic>> timetableData = {
  'A': {
    'section': 'I MCA - A',
    'advisor': 'Dr.K.Chitra & Ms.P.Dharanisri',
    'schedule': {
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '1.30-2.20', 'subject': 'CD', 'faculty': ''},
        {'time': '2.20-3.10', 'subject': 'CD', 'faculty': ''},
        {'time': '3.20-4.10', 'subject': 'SS', 'faculty': ''},
      ],
      'Tue': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'CD', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'SS', 'faculty': ''},
        {'time': '1.30-2.20', 'subject': 'OFC', 'faculty': ''},
        {'time': '2.20-3.10', 'subject': 'OFC', 'faculty': ''},
        {'time': '3.20-4.10', 'subject': 'LAB', 'faculty': ''},
      ],
      'Wed': [
        {'time': '8.45-9.35', 'subject': 'SS', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'CD', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DBT', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'SE', 'faculty': ''},
        {'time': '1.30-2.20', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '2.20-3.10', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '3.20-4.10', 'subject': 'LAB', 'faculty': ''},
      ],
      'Thu': [
        {'time': '8.45-9.35', 'subject': 'DBT', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'SE', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'CD', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'SS', 'faculty': ''},
        {'time': '1.30-2.20', 'subject': 'OFC', 'faculty': ''},
        {'time': '2.20-3.10', 'subject': 'OFC', 'faculty': ''},
        {'time': '3.20-4.10', 'subject': 'LAB', 'faculty': ''},
      ],
      'Fri': [
        {'time': '8.45-9.35', 'subject': 'SS', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '1.30-2.20', 'subject': 'SE', 'faculty': ''},
        {'time': '2.20-3.10', 'subject': 'CD', 'faculty': ''},
        {'time': '3.20-4.10', 'subject': 'LAB', 'faculty': ''},
      ],
      'Sat': [
        {'time': '8.45-9.35', 'subject': 'CD', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'SS', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DBT', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'SE', 'faculty': ''},
        {'time': '1.30-2.20', 'subject': 'LAB', 'faculty': ''},
        {'time': '2.20-3.10', 'subject': 'LAB', 'faculty': ''},
        {'time': '3.20-4.10', 'subject': 'LAB', 'faculty': ''},
      ],
    },
  },
  'B': {
    'section': 'I MCA - B',
    'advisor': 'Dr.K.Chitra & Ms.P.Dharanisri',
    'schedule': {
      // ... (Rest of section B schedule, simplified for brevity but following the pattern)
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'OFC', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'WEB Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'WEB Lab CC1', 'faculty': ''},
        {'time': '1.30-2.20', 'subject': 'OFC', 'faculty': ''},
        {'time': '2.20-3.10', 'subject': 'DSA', 'faculty': ''},
        {'time': '3.20-4.10', 'subject': 'CD', 'faculty': ''},
      ],
      // ... (Other days for Section B)
    },
  },
};

// --- 2. Widget Definition ---
class TimeTableScreen extends StatefulWidget {
  final String facultyName;

  const TimeTableScreen({super.key, required this.facultyName});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  // State to hold the current selections (will be saved to Firebase)
  Map<String, List<Map<String, String>>> _currentSchedule = {};
  bool _isLoading = true;
  bool _isEditing = false; // Flag to indicate if any change has been made
  String _selectedSectionKey = 'A'; // Default section

  @override
  void initState() {
    super.initState();
    // Initialize with the default schedule for the selected section
    _currentSchedule = Map.from(timetableData[_selectedSectionKey]!['schedule'] as Map<String, List<Map<String, String>>>);
    _loadFacultyTimetable();
  }

  // --- Utility Functions ---

  // Function to load the faculty's existing timetable from Firebase
  Future<void> _loadFacultyTimetable() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) print('Error: User not authenticated.');
      _isLoading = false;
      return;
    }

    try {
      // Use the correct path based on user ID
      final docRef = _firestore.collection('faculties').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('timetable')) {
          // Check if there is an existing timetable
          final storedTimetable = data['timetable'] as Map<String, dynamic>;

          // Deep copy and cast the stored timetable to the local state map structure
          Map<String, List<Map<String, String>>> loadedSchedule = {};
          storedTimetable.forEach((day, periods) {
            if (periods is List) {
              // Ensure we convert each period item to Map<String, String>
              loadedSchedule[day] = periods.map((p) => Map<String, String>.from(p as Map)).toList();
            }
          });

          setState(() {
            _currentSchedule = loadedSchedule;
            _isLoading = false;
          });
          return;
        }
      }

      // If no data or document doesn't exist, use the default initialized schedule
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error loading timetable: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to save the timetable to Firebase and navigate home
  void _submitAndGoHome() async {
    setState(() {
      _isLoading = true; // Use loading state during submission
    });

    final user = _auth.currentUser;
    if (user == null) {
      _showSnackBar('User not authenticated.', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Update the timetable in the faculty's document
      final docRef = _firestore.collection('faculties').doc(user.uid);
      await docRef.update({
        'timetable': _currentSchedule,
      });

      _showSnackBar('Timetable updated successfully!', Colors.green);

      // 2. Navigate back to HomeScreen by popping the current route
      if (mounted) {
        // We check if we are currently editing or not. If not editing,
        // we just want to go back. If editing, we submit and go back.
        // We use pop() instead of pushAndRemoveUntil() to go back to the previous screen (HomeScreen)
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) print('Error submitting timetable: $e');
      _showSnackBar('Failed to submit timetable: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to toggle a period's assignment
  void _toggleAssignment(String day, int periodIndex, String facultyCode) {
    // Only allow modification if the schedule is loaded
    if (_isLoading) return; 

    if (!_isEditing) {
      setState(() {
        _isEditing = true;
      });
    }

    setState(() {
      final period = _currentSchedule[day]![periodIndex];
      // Check if the period is currently free (faculty is empty or null)
      final isFree = (period['faculty'] ?? '').isEmpty;

      if (isFree) {
        // Assign the period to the current faculty
        period['faculty'] = facultyCode;
        // Also ensure the section key is added for proper display in HomeScreen
        period['section'] = timetableData[_selectedSectionKey]!['section'];
      } else if (period['faculty'] == facultyCode) {
        // If the period is already assigned to the current faculty, set it back to free
        period['faculty'] = '';
        period.remove('section'); // Remove section when period is free
      } else {
        // If assigned to another faculty, show a message
        _showSnackBar('This period is already assigned to ${period['faculty']}', Colors.orange);
      }
    });
  }

  // --- Widget Builders ---

  // Builds a single tile for a period within a day
  Widget _buildPeriodTile(String day, int index, Map<String, String> period, String facultyCode) {
    final assignedFaculty = period['faculty'] ?? '';
    final isAssignedToSelf = assignedFaculty == facultyCode;
    final isAssignedToOther = assignedFaculty.isNotEmpty && assignedFaculty != facultyCode;

    Color tileColor = Colors.white;
    Color subjectColor = Colors.indigo.shade800;
    String assignmentText = 'Available for Assignment: ${period['subject']}';

    if (isAssignedToSelf) {
      tileColor = Colors.green.shade50;
      subjectColor = Colors.green.shade700;
      assignmentText = 'Assigned to You: ${period['subject']} (${period['section'] ?? 'N/A'})';
    } else if (isAssignedToOther) {
      tileColor = Colors.red.shade50;
      subjectColor = Colors.red.shade700;
      assignmentText = 'Taken by: $assignedFaculty (${period['subject']})';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: tileColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          period['time']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          assignmentText,
          style: TextStyle(color: subjectColor),
        ),
        trailing: isAssignedToSelf
            ? const Icon(Icons.check_circle, color: Colors.green)
            : isAssignedToOther
                ? const Icon(Icons.lock, color: Colors.red)
                : const Icon(Icons.add_circle_outline, color: Colors.grey),
        onTap: isAssignedToOther ? null : () {
          // Faculty code is simplified to the full name for now for identification
          _toggleAssignment(day, index, facultyCode);
        },
      ),
    );
  }

  // Builds the schedule list for a given day
  Widget _buildDaySchedule(String day, String facultyCode) {
    final schedule = _currentSchedule[day];

    if (schedule == null) {
      return const Center(child: Text('No schedule data found for this day.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: Text(
            '$day Schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedule.length,
          itemBuilder: (context, index) {
            return _buildPeriodTile(day, index, schedule[index], facultyCode);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String facultyCode = widget.facultyName; // Using the full name as the unique code for assignments

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.facultyName}\'s Timetable'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100), // Space for submit button
                  child: Column(
                    children: [
                      // Faculty/Admin Greeting
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _isEditing
                              ? 'Unsaved changes! Tap Submit to save.'
                              : 'Tap on an available period to assign it to yourself, or tap again to unassign.',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isEditing ? Colors.red.shade700 : Colors.black87,
                            fontWeight: _isEditing ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      // List of schedules for each day
                      ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
                        return _buildDaySchedule(day, facultyCode);
                      }).toList(),
                    ],
                  ),
                ),

                // Submit Button Section at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      // Enable button regardless of _isEditing, so user can also use it to navigate back after saving.
                      onPressed: _submitAndGoHome, 
                      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                      label: Text(
                        _isLoading 
                            ? 'Submitting...' 
                            : (_isEditing ? 'Submit Changes & Go Home' : 'Go Back to Home Screen'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        // Change color based on if there are changes to submit
                        backgroundColor: _isEditing ? Colors.indigo : Colors.blueGrey.shade400, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}