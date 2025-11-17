import 'package:flutter/material.dart';
import 'package:pooja/screens/profile_screen.dart';
import 'package:pooja/screens/timetable_screen.dart';
// REMOVED: import 'package:pooja/screens/login_screen.dart'; 

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
      String facultyCode = period['faculty'] ?? '';
      String section = period['section'] ?? 'I MCA';

      assignments.add(Assignment(
        day: day,
        time: period['time'] ?? 'N/A',
        subject: period['subject'] ?? 'N/A',
        facultyCode: facultyCode,
        section: section,
      ));
    });
  });
  return assignments;
}

// --- 2. WIDGET: VerticalTimeline to display the schedule ---
class VerticalTimeline extends StatelessWidget {
  final List<Assignment> assignments;
  final String totalHours;

  const VerticalTimeline({
    super.key,
    required this.assignments,
    required this.totalHours,
  });

  @override
  Widget build(BuildContext context) {
    // Show empty state message if no assignments exist
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 50, color: Colors.indigo.shade400),
            const SizedBox(height: 10),
            const Text(
              'No Timetable Approved Yet.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            const Text(
              'Tap the Edit button to submit your schedule.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    // -----------------------------------------------------------------

    final Map<String, List<Assignment>> assignmentsByDay = {};
    for (var assignment in assignments) {
      assignmentsByDay.putIfAbsent(assignment.day, () => []).add(assignment);
    }

    final List<String> sortedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        .where((day) => assignmentsByDay.containsKey(day))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approved Weekly Schedule',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
          ),
          Text(
            'Total Teaching Load: $totalHours',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade700),
          ),
          const Divider(thickness: 2),
          ...sortedDays.map((day) {
            final dailyAssignments = assignmentsByDay[day]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
                  child: Text(
                    '${day.toUpperCase()}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.indigo.shade600),
                  ),
                ),
                _buildDailyTimeline(dailyAssignments),
              ],
            );
          }).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDailyTimeline(List<Assignment> dailyAssignments) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dailyAssignments.length,
      itemBuilder: (context, index) {
        final assignment = dailyAssignments[index];
        final isLast = index == dailyAssignments.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 25,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.indigo.shade100, width: 2),
                      ),
                    ),
                    isLast
                        ? const SizedBox(height: 10)
                        : Expanded(
                              child: Container(width: 2, color: Colors.grey.shade400),
                            ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Display subject and time clearly
                        '${assignment.subject} (${assignment.time})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                      Text(
                        'Section: ${assignment.section} | Faculty Code: ${assignment.facultyCode}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 5),
                      // NOTE: Placeholder bullet points are currently hardcoded
                      _buildBulletPoint('Home work (e.g., set theory problems)'),
                      _buildBulletPoint('Project (e.g., database design review)'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(fontSize: 16, color: Colors.green)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}

// --- 3. HomeScreen StatefulWidget ---
class HomeScreen extends StatefulWidget {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String phoneNo;
  final List<String> assignments;

  const HomeScreen({
    super.key,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNo,
    required this.assignments,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0: Timetable View, 1: Profile View
  int _selectedIndex = 0; 
  List<Assignment> _submittedSchedule = [];
  String _totalHours = '0 hours 0 minutes';

  String get _fullName {
    final middle = widget.middleName != null && widget.middleName!.isNotEmpty ? '${widget.middleName} ' : '';
    return '${widget.firstName} $middle${widget.lastName}';
  }

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _calculateTotalHours(_submittedSchedule);
    _initializeWidgetOptions();
  }

  // REMOVED: _navigateToLogin function (The logic is now in ProfileScreen)
  /* void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, 
    );
  }
  */

  void _initializeWidgetOptions() {
    // Re-initialize widget options using the current state variables
    _widgetOptions = <Widget>[
      // Index 0: Home Content (Timetable)
      VerticalTimeline(assignments: _submittedSchedule, totalHours: _totalHours),
      
      // Index 1: Profile Screen Content
      ProfileScreen(
        firstName: widget.firstName,
        middleName: widget.middleName,
        lastName: widget.lastName,
        email: widget.email,
        phoneNo: widget.phoneNo,
        assignments: widget.assignments,
        // REMOVED: onNavigateHome: () => _onItemTapped(0), 
        // REMOVED: onLogout: _navigateToLogin, 
      ),
    ];
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure widget options are updated if parent widget data changes
    _initializeWidgetOptions();
  }

  void _calculateTotalHours(List<Assignment> schedule) {
    const int periodDurationMinutes = 50;
    int totalMinutes = schedule.length * periodDurationMinutes;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (mounted) {
      setState(() {
        _totalHours = '$hours hours $minutes minutes';
        // Re-initialize widget options to update VerticalTimeline with new _totalHours
        _initializeWidgetOptions();
      });
    } else {
      _totalHours = '$hours hours $minutes minutes';
    }
  }

  void _navigateToTimetable() async {
    // The TimeTableScreen returns the selected schedule as a Map
    final selectedScheduleMap = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimeTableScreen(facultyName: _fullName),
      ),
    );

    // Check if data was returned and if it's the correct type
    if (selectedScheduleMap != null && selectedScheduleMap is Map<String, List<Map<String, String>>>) {
      final newSchedule = parseScheduleMap(selectedScheduleMap);
      
      // Update state, calculate hours, and re-initialize widget options
      setState(() {
        _submittedSchedule = newSchedule;
        // _calculateTotalHours will call setState and _initializeWidgetOptions internally
        _calculateTotalHours(_submittedSchedule);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable has been updated successfully!')),
      );
    }
  }

  // Method to handle switching tabs for internal navigation (e.g., Profile)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Helper widget for the custom bottom navigation items
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? Colors.indigo : Colors.grey.shade600;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.firstName}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        // Left corner icon: Search
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(Icons.search, color: Colors.white, size: 28),
        ),
        actions: const [
          // Right corner icon: Bell/Notification
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: null, // Placeholder action
            tooltip: 'Notifications',
          ),
        ],
      ),
      
      // Displays the selected widget from _widgetOptions list
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), 
      ),
      
      // FloatingActionButton is removed as per the new bottom nav structure
      floatingActionButton: null,
      
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
              isSelected: false, // Not part of the internal selection
              onTap: _navigateToTimetable,
            ),
            
            // 2. Home Icon (Center) - Internal Navigation
            _buildBottomNavItem(
              icon: Icons.home,
              label: 'Home', 
              // Highlight the Home icon if currently on the Home content tab
              isSelected: _selectedIndex == 0,
              // Switches to the Home view internally
              onTap: () => _onItemTapped(0), 
            ),
            
            // 3. Profile Icon (Right) - Internal Navigation
            _buildBottomNavItem(
              icon: Icons.person,
              label: 'Profile',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1), // Switches to the Profile content tab
            ),
          ],
        ),
      ),
    );
  }
}