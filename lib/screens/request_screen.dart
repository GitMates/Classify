import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

// ----------------------------------------------------------------------
// Data Models for Communication and Filtering
// ----------------------------------------------------------------------

// Model to hold the data of the period needing substitution
class PeriodToSubstitute {
  final String day;
  final String timeSlot; // e.g., "9.35-10.25"
  final String subject;
  final String section;
  final String requesterFacultyId;
  final String requesterFacultyName;

  PeriodToSubstitute({
    required this.day,
    required this.timeSlot,
    required this.subject,
    required this.section,
    required this.requesterFacultyId,
    required this.requesterFacultyName,
  });

  // Helper to check if a faculty member is busy during this specific period
  bool isBusy(List<dynamic> assignments) {
    // Check if any period in the list matches the requested timeSlot.
    return assignments.any((assignment) =>
        assignment is Map && assignment['time'] == timeSlot); // Ensure assignment is a Map before access
  }
}

// Model to simplify faculty data display
class AvailableFaculty {
  final String id;
  final String name;
  final String email;

  AvailableFaculty({
    required this.id,
    required this.name,
    required this.email,
  });
}

// ----------------------------------------------------------------------
// Request Screen Implementation
// ----------------------------------------------------------------------

class RequestScreen extends StatefulWidget {
  final PeriodToSubstitute period;

  const RequestScreen({super.key, required this.period});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AvailableFaculty> _availableFaculty = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAvailableFaculty();
  }

  // 🌟 LOGIC TO FIND AVAILABLE FACULTY (Already correct) 🌟
  Future<void> _fetchAvailableFaculty() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final period = widget.period;
      // 1. Get all faculty profiles
      final snapshot = await _firestore.collection('facultyProfiles').get();

      List<AvailableFaculty> available = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final facultyId = doc.id;
        
        // Skip the faculty member who is making the request
        if (facultyId == period.requesterFacultyId) continue; 
        
        // Combine all assignments for the requested day across all timetables (A, B, etc.)
        List<dynamic> allDayPeriods = [];

        data.forEach((key, value) {
          // Look for keys that start with 'timetable_' (e.g., timetable_A, timetable_B)
          if (key.startsWith('timetable_') && value is Map) {
            final scheduleMap = value as Map<String, dynamic>;
            
            // Check if the schedule contains periods for the day being requested
            if (scheduleMap.containsKey(period.day) && scheduleMap[period.day] is List) {
              // Add all periods for that day to the combined list
              allDayPeriods.addAll(scheduleMap[period.day] as List<dynamic>);
            }
          }
        });

        // Safely extract names and email
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final email = data['email'] ?? '';
        final fullName = '$firstName $lastName';
        
        // 2. Check if the faculty is busy during the requested time
        final isBusy = period.isBusy(allDayPeriods);

        if (!isBusy) {
          // 3. If NOT busy, add them to the available list
          available.add(AvailableFaculty(
            id: facultyId,
            name: fullName,
            email: email,
          ));
        }
      }

      setState(() {
        _availableFaculty = available;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load faculty: $e';
        _isLoading = false;
      });
      if (kDebugMode) debugPrint('Error fetching faculty: $e');
    }
  }

  // 🌟 LOGIC TO SEND SUBSTITUTION REQUEST (Already correct) 🌟
  Future<void> _sendRequest(AvailableFaculty receiver) async {
    try {
      final period = widget.period;

      // 1. Create a document in the substitutionRequests collection
      await _firestore.collection('substitutionRequests').add({
        'requesterId': period.requesterFacultyId,
        'requesterName': period.requesterFacultyName,
        'receiverId': receiver.id,
        'receiverName': receiver.name,
        'day': period.day,
        'timeSlot': period.timeSlot,
        'subject': period.subject,
        'section': period.section,
        'status': 'Pending', // Initial status
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent to ${receiver.name} successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Substitute'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card showing the period details
                    Card(
                      margin: const EdgeInsets.all(16.0),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Period Needing Cover:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade800),
                            ),
                            const SizedBox(height: 8),
                            Text('Day: ${widget.period.day}', style: const TextStyle(fontSize: 16)),
                            Text('Time: ${widget.period.timeSlot}', style: const TextStyle(fontSize: 16)),
                            Text('Class: ${widget.period.section} (${widget.period.subject})', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Available Faculty for this Slot:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // List of Available Faculty
                    Expanded(
                      child: _availableFaculty.isEmpty
                          ? const Center(
                              child: Text('No faculty available for this period.'),
                            )
                          : ListView.builder(
                              itemCount: _availableFaculty.length,
                              itemBuilder: (context, index) {
                                final faculty = _availableFaculty[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: ListTile(
                                    leading: const Icon(Icons.person_pin, color: Colors.green),
                                    title: Text(faculty.name),
                                    subtitle: Text(faculty.email),
                                    // 🌟 THE REQUEST BUTTON (Already correct) 🌟
                                    trailing: ElevatedButton(
                                      onPressed: () => _sendRequest(faculty),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('REQUEST'),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}