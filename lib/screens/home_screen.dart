import 'package:flutter/material.dart';
// --- NEW IMPORTS FOR FIREBASE, INT'L, AND UTILITIES ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode print statements
// -----------------------------------------------------

import 'package:pooja/screens/profile_screen.dart';
import 'package:pooja/screens/timetable_screen.dart';


// --- 0. DATA MODEL: Define the Assignment model ---
class Assignment {
  final String day;
  final String time;
  final String subject;
  final String facultyCode;
  final String section;

  Assignment({
    required this.day,
    required this.time,
    required this.subject,
    required this.facultyCode,
    required this.section,
  });
}

// --- 1. Utility function to parse the raw map into Assignment list ---
List<Assignment> parseScheduleMap(Map<String, List<Map<String, String>>> scheduleMap) {
  List<Assignment> assignments = [];

  scheduleMap.forEach((day, periods) {
    periods.forEach((period) {
      // Use 'section' from the period map if available, otherwise default to 'I MCA'
      String section = period['section'] ?? 'I MCA'; 

      assignments.add(Assignment(
        day: day,
        time: period['time'] ?? 'N/A',
        subject: period['subject'] ?? 'N/A',
        facultyCode: period['faculty'] ?? '',
        section: section,
      ));
    });
  });
  return assignments;
}

// --- 2. HomeScreen Widget ---
class HomeScreen extends StatefulWidget {
  // NEW: Accept facultyName for personalized greeting/header
  final String facultyName; 

  const HomeScreen({super.key, required this.facultyName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0 for Home (Timetable), 1 for Profile

  // New state variables for timetable display
  List<Assignment> _currentDaySchedule = [];
  bool _isLoading = true;
  String _currentDayName = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Get the current day abbreviation (Mon, Tue, Wed, etc.)
    _currentDayName = _getCurrentDayAbbreviation(); 
    _fetchTimetable();
  }

  // Helper to get the current day's name (e.g., "Mon", "Tue")
  String _getCurrentDayAbbreviation() {
    // DateFormat('EEE') returns 'Sat', 'Mon', etc., matching your timetable keys.
    return DateFormat('EEE').format(DateTime.now()); 
  }

  // Function to fetch the selected timetable from Firestore
  Future<void> _fetchTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not authenticated. Please log in again.';
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Fetch the faculty document using the current user's UID
      final docRef = FirebaseFirestore.instance.collection('faculties').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data();
        
        if (data != null && data.containsKey('timetable')) {
          final rawSchedule = data['timetable'] as Map<String, dynamic>;

          // Safely cast and process the raw schedule map
          final Map<String, List<Map<String, String>>> scheduleMap = {};
          rawSchedule.forEach((day, periods) {
            if (periods is List) {
              scheduleMap[day] = periods.map((p) => Map<String, String>.from(p as Map)).toList();
            }
          });

          final allAssignments = parseScheduleMap(scheduleMap);
          
          // 2. Filter assignments for the current day
          final todaySchedule = allAssignments
              .where((a) => a.day == _currentDayName)
              .toList();

          // 3. Sort by time (crucial for a timeline view)
          todaySchedule.sort((a, b) => a.time.compareTo(b.time));

          setState(() {
            _currentDaySchedule = todaySchedule;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Timetable data not found for your account.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Faculty profile not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching timetable: $e');
      }
      setState(() {
        _errorMessage = 'Failed to load timetable. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  // --- Helper Widget for the Timeline Item UI ---
  Widget _buildTimelineItem(Assignment assignment, bool isLast) {
    // Determine a color for visual appeal
    Color periodColor = Colors.indigo.shade700; 
    // You could customize this based on subject, time, etc.

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      // IntrinsicHeight ensures the timeline line stretches vertically with the card
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Left Column: Time and Timeline Marker ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                Text(
                  assignment.time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Timeline Marker (Circle)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: periodColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: periodColor.withOpacity(0.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                // Vertical Line (The timeline connecting the markers)
                Expanded(
                  child: Visibility(
                    visible: !isLast, // Hide the line for the last item
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(left: 7.0),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),

            // --- Right Column: Class Details Card ---
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  // Left border accent for visual hierarchy
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: periodColor, width: 5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject/Course Name
                      Text(
                        assignment.subject.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: periodColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Section/Division
                      Text(
                        'Section: ${assignment.section}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Faculty Code (or Name)
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: Colors.indigo.shade400),
                          const SizedBox(width: 5),
                          Text(
                            'Faculty Code: ${assignment.facultyCode.isNotEmpty ? assignment.facultyCode : 'Self'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Main Content: The Home View ---
  Widget _buildHomeContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                onPressed: _fetchTimetable,
              ),
            ],
          ),
        ),
      );
    }

    // --- TimeTable Display ---
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and Current Day Header
          Text(
            'Hello, ${widget.facultyName}!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Today is $_currentDayName. Your Schedule:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const Divider(height: 30, thickness: 1),

          // Timeline Content
          Expanded(
            child: _currentDaySchedule.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                        SizedBox(height: 10),
                        Text(
                          '🎉 Free! No classes scheduled for today.',
                          style: TextStyle(fontSize: 18, color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _currentDaySchedule.length,
                    itemBuilder: (context, index) {
                      final assignment = _currentDaySchedule[index];
                      // Check if it's the last item to hide the vertical line
                      final isLast = index == _currentDaySchedule.length - 1; 
                      return _buildTimelineItem(assignment, isLast);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Navigation Handlers ---

  // Navigates to the TimetableScreen (passing the current faculty name)
  void _navigateToTimetable() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimeTableScreen(
          facultyName: widget.facultyName,
        ),
      ),
    );
  }

  // Switches the content view (Home or Profile)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper for the Bottom Navigation Bar Items
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? Colors.indigo.shade800 : Colors.grey.shade600,
              size: 28,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.indigo.shade800 : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine the content based on the selected index
    final List<Widget> _widgetOptions = <Widget>[
      _buildHomeContent(context), // Index 0: Home (Timetable)
      ProfileScreen( // Index 1: Profile
        // Note: The ProfileScreen requires real user data, 
        // which should ideally be passed from the login/fetched here. 
        // For now, using placeholders/data from the Home constructor for continuity.
        firstName: widget.facultyName.split(' ').first,
        lastName: widget.facultyName.split(' ').last,
        email: FirebaseAuth.instance.currentUser?.email ?? 'loading@example.com',
        phoneNo: 'N/A', // Placeholder
        assignments: const [], // Placeholder: Needs to be fetched if required
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Portal'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevents back button to login/register
      ),
      
      body: _widgetOptions.elementAt(_selectedIndex),

      // Custom Bottom Bar (Timetable, Home, Profile)
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // 1. Timetable Icon (Left) - External Navigation
            _buildBottomNavItem(
              icon: Icons.calendar_month, // Using a clear calendar icon
              label: 'Timetable',
              isSelected: false, 
              onTap: _navigateToTimetable,
            ),
            
            // 2. Home Icon (Center) - Internal Navigation
            _buildBottomNavItem(
              icon: Icons.home,
              label: 'Home', 
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0), 
            ),
            
            // 3. Profile Icon (Right) - Internal Navigation
            _buildBottomNavItem(
              icon: Icons.person,
              label: 'Profile',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1), 
            ),
          ],
        ),
      ),
    );
  }
}