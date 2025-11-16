// lib/screens/timetable_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pooja/screens/login_screen.dart';
import 'package:pooja/screens/faculty_dashboard.dart'; // Import the new dashboard

// --- 1. Timetable Data Structure ---
const Map<String, Map<String, dynamic>> timetableData = {
  'A': {
    'section': 'I MCA - A',
    'advisor': 'Dr.K.Chitra & Ms.P.Dharanisti',
    'schedule': {
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'CP', 'faculty': 'SH,TK'},
        {'time': '2.15-3.05', 'subject': 'CP', 'faculty': 'SH,TK'},
        {'time': '3.25-4.15', 'subject': 'PSP', 'faculty': ''},
      ],
      'Tue': [
        {'time': '8.45-9.35', 'subject': 'DBT', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'SE', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'AM', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'OS (PD)/P&T (PV)', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'DSA', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'CP', 'faculty': ''},
      ],
      'Wed': [
        {'time': '8.45-9.35', 'subject': 'AM', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'MP - I', 'faculty': 'KC'},
        {'time': '2.15-3.05', 'subject': 'MP - I', 'faculty': 'KC'},
        {'time': '3.25-4.15', 'subject': 'MP - I', 'faculty': ''},
      ],
      'Thu': [
        {'time': '8.45-9.35', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'PSP (T) CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'PSP (T) CC1', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'AM', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'SE', 'faculty': ''},
      ],
      'Fri': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'AM', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'COD (KC)/P&T (PD)', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'PSP', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'Portal (CC1)', 'faculty': ''},
      ],
      'Sat': [
        {'time': '8.45-9.35', 'subject': 'OS (PD)/P&T (TK)', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'COD (KC)/P&T (SH)', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'COD (KC)/P&T (SH)', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'COD (KC)/P&T (SH)', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'COUN (SH)', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'SPD (MJ)', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'LIB (MJ)', 'faculty': ''},
      ],
    },
  },
  'B': {
    'section': 'I MCA - B',
    'advisor': 'Ms.T.Kalpana & Mr.S.R.Karthikeyan',
    'schedule': {
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'DSA', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'AM', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'CP', 'faculty': 'PV, MP'},
        {'time': '2.15-3.05', 'subject': 'CP', 'faculty': 'PV, MP'},
        {'time': '3.25-4.15', 'subject': 'DSA', 'faculty': ''},
      ],
      'Tue': [
        {'time': '8.45-9.35', 'subject': 'DBT', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'AM', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DBT Lab CC2', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DBT Lab CC2', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'OS (PD)/P&T (SBK)', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'SE', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'MP - I', 'faculty': ''},
      ],
      'Wed': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'AM', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'PSP', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'MP - I (CC2)', 'faculty': 'SBK'},
        {'time': '2.15-3.05', 'subject': 'MP - I (CC2)', 'faculty': 'SBK'},
        {'time': '3.25-4.15', 'subject': 'MP - I', 'faculty': ''},
      ],
      'Thu': [
        {'time': '8.45-9.35', 'subject': 'DBT Lab CC2', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT Lab CC2', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'PSP (T) CC2', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'PSP (T) CC2', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'DSA', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'DBT', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'SE', 'faculty': ''},
      ],
      'Fri': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'AM', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'COD (KC)/P&T (PV)', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'PSP', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'Portal (CC2)', 'faculty': ''},
      ],
      'Sat': [
        {'time': '8.45-9.35', 'subject': 'OS (PD)/P&T (TKL)', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'OS (PD)/P&T (SBK)', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'COD (KC)/P&T (MS)', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'COD (KC)/P&T (MS)', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'LIB (PV)', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'COUN (MP)', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'SPD (PV)', 'faculty': ''},
      ],
    },
  },
};

// --- 2. TimeTableScreen StatefulWidget ---
class TimeTableScreen extends StatefulWidget {
  final String facultyName;

  const TimeTableScreen({super.key, required this.facultyName});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  String _selectedSection = 'A'; // Default to Section A
  bool _isEditing = true; // Toggle edit mode
  Map<int, Set<int>> _selectedPeriods = {};

  final List<String> days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _initializeSelectedPeriods();
  }

  // Initialize/reset selected periods
  void _initializeSelectedPeriods() {
    setState(() {
      _selectedPeriods = {};
      for (int i = 0; i < days.length; i++) {
        _selectedPeriods[i] = <int>{};
      }
    });
  }

  // Logout handler
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Ignore if not initialized
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Toggle period selection
  void _togglePeriodSelection(int dayIndex, int periodIndex) {
    if (!_isEditing) return;

    setState(() {
      if (_selectedPeriods[dayIndex]!.contains(periodIndex)) {
        _selectedPeriods[dayIndex]!.remove(periodIndex);
      } else {
        _selectedPeriods[dayIndex]!.add(periodIndex);
      }
    });
  }

  // Submit selected timetable
  void _submitTimetable() {
    final Map<String, List<Map<String, String>>> facultySchedule = {};
    final currentSchedule = timetableData[_selectedSection]!['schedule'] as Map<String, List<Map<String, dynamic>>>;

    for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final day = days[dayIndex];
      final List<Map<String, String>> dailyPeriods = [];
      final periods = currentSchedule[day] ?? [];

      for (final periodIndex in _selectedPeriods[dayIndex]!) {
        if (periodIndex < periods.length) {
          dailyPeriods.add(
            periods[periodIndex].map((k, v) => MapEntry(k, v.toString())),
          );
        }
      }

      if (dailyPeriods.isNotEmpty) {
        facultySchedule[day] = dailyPeriods;
      }
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FacultyDashboardScreen(
            facultyName: widget.facultyName,
            selectedSchedule: facultySchedule,
          ),
        ),
      );
    }
  }

  // Get period details safely
  Map<String, dynamic> _getPeriodDetail(String day, int periodIndex) {
    final schedule = timetableData[_selectedSection]!['schedule'] as Map<String, dynamic>;
    final dailyPeriods = schedule[day] as List<Map<String, dynamic>>? ?? [];

    if (periodIndex >= 0 && periodIndex < dailyPeriods.length) {
      return dailyPeriods[periodIndex];
    }
    return {'time': 'N/A', 'subject': 'Break/Free', 'faculty': ''};
  }

  // Build a single timetable cell
  Widget _buildTimetableCell(int dayIndex, int periodIndex) {
    final day = days[dayIndex];
    final period = _getPeriodDetail(day, periodIndex);
    final isSelected = _selectedPeriods[dayIndex]!.contains(periodIndex);
    final isSelectable = period['subject'] != 'Break/Free' && period['time'] != 'N/A';

    final Color darkGreen = Colors.green.shade700;
    final Color lightGreen = Colors.green.shade50;

    Color cardColor = isSelected ? lightGreen : Colors.white;
    if (!_isEditing && !isSelected) {
      cardColor = Colors.grey.shade100;
    }

    final textColor = isSelectable
        ? (isSelected ? darkGreen : Colors.black87)
        : Colors.grey.shade500;

    final String subjectText = period['subject']?.toString() ?? 'N/A';
    final String facultyCode = (period['faculty']?.toString().isEmpty ?? true)
        ? ''
        : '(${period['faculty']})';

    return InkWell(
      onTap: (_isEditing && isSelectable)
          ? () => _togglePeriodSelection(dayIndex, periodIndex)
          : null,
      child: Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(
            color: isSelected ? darkGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected && _isEditing
              ? [BoxShadow(color: darkGreen.withOpacity(0.2), blurRadius: 3, offset: const Offset(0, 1))]
              : null,
        ),
        constraints: const BoxConstraints(minHeight: 70.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subjectText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (facultyCode.isNotEmpty)
              Text(
                facultyCode,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            if (isSelected)
              Icon(Icons.check_circle_outline, size: 14, color: darkGreen),
          ],
        ),
      ),
    );
  }

  // Build full timetable table
  Widget _buildFullTimetableTable() {
    final scheduleA = timetableData['A']!['schedule'] as Map<String, List<Map<String, dynamic>>>;
    final timeSlots = scheduleA[days.first]?.map((p) => p['time'] as String).toList() ?? [];

    if (timeSlots.isEmpty) {
      return const Center(child: Text('Timetable data is unavailable.'));
    }

    final List<TableRow> tableRows = [];

    // Header Row
    tableRows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.indigo.shade100),
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text(
              'Time',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          ),
          ...days.map((day) => Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              )),
        ],
      ),
    );

    // Data Rows
    for (int periodIndex = 0; periodIndex < timeSlots.length; periodIndex++) {
      tableRows.add(
        TableRow(
          children: [
            // Time Slot
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
              ),
              alignment: Alignment.center,
              constraints: const BoxConstraints(minHeight: 70.0),
              child: Text(
                timeSlots[periodIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.indigo),
              ),
            ),
            // Day Cells
            ...List.generate(days.length, (dayIndex) {
              return _buildTimetableCell(dayIndex, periodIndex);
            }),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.indigo.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'I MCA - $_selectedSection Timetable\nAdvisor: ${timetableData[_selectedSection]!['advisor']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),

            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Tap cells to select periods. Scroll right to see all days.',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 5),

            // Horizontal Scrollable Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicWidth(
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(100.0),
                  columnWidths: const {0: FixedColumnWidth(80.0)},
                  border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
                  children: tableRows,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.facultyName.split(' ')[0]}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Section Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: DropdownButton<String>(
              value: _selectedSection,
              dropdownColor: Colors.indigo.shade700,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSection = newValue!;
                  _initializeSelectedPeriods();
                });
              },
              items: <String>['A', 'B'].map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('Section $value'),
                );
              }).toList(),
            ),
          ),
          // Edit Toggle
          IconButton(
            icon: Icon(_isEditing ? Icons.lock_open : Icons.lock,
                color: _isEditing ? Colors.amberAccent : Colors.white),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isEditing
                      ? 'Selection is now enabled (Edit Mode).'
                      : 'Selection is now fixed (View Mode).'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: _isEditing ? 'Fix Selection' : 'Edit Selection',
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildFullTimetableTable(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _isEditing ? null : _submitTimetable,
          icon: const Icon(Icons.save),
          label: Text(_isEditing ? 'Submit (Fix Selection First)' : 'Submit Timetable'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing ? Colors.grey : Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

// Removed unnecessary extension