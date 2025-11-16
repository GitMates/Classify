// lib/screens/timetable_screen.dart (NO MAJOR CHANGES NEEDED HERE FOR THE INITIAL ISSUE)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pooja/screens/login_screen.dart';
// import 'package:pooja/screens/home_screen.dart'; // Not needed here

// --- Extension for Set (Assuming you have this, otherwise see note above) ---
extension SetToggle<T> on Set<T> {
  void toggle(T value) {
    if (contains(value)) {
      remove(value);
    } else {
      add(value);
    }
  }
}

// --- 1. Timetable Data Structure ---
const Map<String, Map<String, dynamic>> timetableData = {
  'A': {
    'section': 'I MCA - A',
    'advisor': 'Dr.K.Chitra & Ms.P.Dharanisri',
    'schedule': {
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': 'TK'},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': 'PD'},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC1', 'faculty': 'KC'},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC1', 'faculty': 'KC'},
        {'time': '1.25-2.15', 'subject': 'CP', 'faculty': 'SH,TK'},
        {'time': '2.15-3.05', 'subject': 'CP', 'faculty': 'SH,TK'},
        {'time': '3.25-4.15', 'subject': 'PSP', 'faculty': 'MP'},
      ],
      'Tue': [
        {'time': '8.45-9.35', 'subject': 'DBT', 'faculty': 'PD'},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': 'SH'},
        {'time': '10.45-11.35', 'subject': 'SE', 'faculty': 'TK'},
        {'time': '11.35-12.25', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '1.25-2.15', 'subject': 'OS (PD)/P&T (PV)', 'faculty': 'PD,PV'},
        {'time': '2.15-3.05', 'subject': 'DSA', 'faculty': 'SH'},
        {'time': '3.25-4.15', 'subject': 'CP', 'faculty': 'TK'},
      ],
      'Wed': [
        {'time': '8.45-9.35', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': 'SH'},
        {'time': '10.45-11.35', 'subject': 'DBT Lab CC1', 'faculty': 'PD'},
        {'time': '11.35-12.25', 'subject': 'DBT Lab CC1', 'faculty': 'PD'},
        {'time': '1.25-2.15', 'subject': 'MP - I', 'faculty': 'KC'},
        {'time': '2.15-3.05', 'subject': 'MP - I', 'faculty': 'KC'},
        {'time': '3.25-4.15', 'subject': 'MP - I', 'faculty': 'KC'},
      ],
      'Thu': [
        {'time': '8.45-9.35', 'subject': 'DBT Lab CC1', 'faculty': 'PD'},
        {'time': '9.35-10.25', 'subject': 'DBT Lab CC1', 'faculty': 'PD'},
        {'time': '10.45-11.35', 'subject': 'PSP (T) CC1', 'faculty': 'MP'},
        {'time': '11.35-12.25', 'subject': 'PSP (T) CC1', 'faculty': 'MP'},
        {'time': '1.25-2.15', 'subject': 'DSA Lab CC1', 'faculty': 'SH'},
        {'time': '2.15-3.05', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '3.25-4.15', 'subject': 'SE', 'faculty': 'TK'},
      ],
      'Fri': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': 'TK'},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': 'PD'},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC1', 'faculty': 'SH'},
        {'time': '11.35-12.25', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '1.25-2.15', 'subject': 'COD (KC)/P&T (PD)', 'faculty': 'KC,PD'},
        {'time': '2.15-3.05', 'subject': 'PSP', 'faculty': 'MP'},
        {'time': '3.25-4.15', 'subject': 'Portal (CC1)', 'faculty': 'SH'},
      ],
      'Sat': [
        {'time': '8.45-9.35', 'subject': 'OS (PD)/P&T (TK)', 'faculty': 'PD,TK'},
        {'time': '9.35-10.25', 'subject': 'COD (KC)/P&T (SH)', 'faculty': 'KC,SH'},
        {'time': '10.45-11.35', 'subject': 'COD (KC)/P&T (SH)', 'faculty': 'KC,SH'},
        {'time': '11.35-12.25', 'subject': 'COD (KC)/P&T (SH)', 'faculty': 'KC,SH'},
        {'time': '1.25-2.15', 'subject': 'COUN (SH)', 'faculty': 'SH'},
        {'time': '2.15-3.05', 'subject': 'SPD (MJ)', 'faculty': 'MJ'},
        {'time': '3.25-4.15', 'subject': 'LIB (MJ)', 'faculty': 'MJ'},
      ],
    },
  },
  'B': {
    'section': 'I MCA - B',
    'advisor': 'Ms.T.Kalpana & Mr.S.R.Karthikeyan',
    'schedule': {
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'DSA', 'faculty': 'SH'},
        {'time': '9.35-10.25', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC2', 'faculty': 'SH'},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC2', 'faculty': 'SH'},
        {'time': '1.25-2.15', 'subject': 'CP', 'faculty': 'PV, MP'},
        {'time': '2.15-3.05', 'subject': 'CP', 'faculty': 'PV, MP'},
        {'time': '3.25-4.15', 'subject': 'DSA', 'faculty': 'SH'},
      ],
      'Tue': [
        {'time': '8.45-9.35', 'subject': 'DBT', 'faculty': 'PD'},
        {'time': '9.35-10.25', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '10.45-11.35', 'subject': 'DBT Lab CC2', 'faculty': 'PD'},
        {'time': '11.35-12.25', 'subject': 'DBT Lab CC2', 'faculty': 'PD'},
        {'time': '1.25-2.15', 'subject': 'OS (PD)/P&T (SBK)', 'faculty': 'PD,SBK'},
        {'time': '2.15-3.05', 'subject': 'SE', 'faculty': 'TK'},
        {'time': '3.25-4.15', 'subject': 'MP - I', 'faculty': 'KC'},
      ],
      'Wed': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': 'TK'},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': 'PD'},
        {'time': '10.45-11.35', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '11.35-12.25', 'subject': 'PSP', 'faculty': 'MP'},
        {'time': '1.25-2.15', 'subject': 'MP - I (CC2)', 'faculty': 'SBK'},
        {'time': '2.15-3.05', 'subject': 'MP - I (CC2)', 'faculty': 'SBK'},
        {'time': '3.25-4.15', 'subject': 'MP - I', 'faculty': 'SBK'},
      ],
      'Thu': [
        {'time': '8.45-9.35', 'subject': 'DBT Lab CC2', 'faculty': 'PD'},
        {'time': '9.35-10.25', 'subject': 'DBT Lab CC2', 'faculty': 'PD'},
        {'time': '10.45-11.35', 'subject': 'PSP (T) CC2', 'faculty': 'MP'},
        {'time': '11.35-12.25', 'subject': 'PSP (T) CC2', 'faculty': 'MP'},
        {'time': '1.25-2.15', 'subject': 'DSA', 'faculty': 'SH'},
        {'time': '2.15-3.05', 'subject': 'DBT', 'faculty': 'PD'},
        {'time': '3.25-4.15', 'subject': 'SE', 'faculty': 'TK'},
      ],
      'Fri': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': 'TK'},
        {'time': '9.35-10.25', 'subject': 'AM', 'faculty': 'PV'},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC2', 'faculty': 'SH'},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC2', 'faculty': 'SH'},
        {'time': '1.25-2.15', 'subject': 'COD (KC)/P&T (PV)', 'faculty': 'KC,PV'},
        {'time': '2.15-3.05', 'subject': 'PSP', 'faculty': 'MP'},
        {'time': '3.25-4.15', 'subject': 'Portal (CC2)', 'faculty': 'PV'},
      ],
      'Sat': [
        {'time': '8.45-9.35', 'subject': 'OS (PD)/P&T (TKL)', 'faculty': 'PD,TK'},
        {'time': '9.35-10.25', 'subject': 'OS (PD)/P&T (SBK)', 'faculty': 'PD,SBK'},
        {'time': '10.45-11.35', 'subject': 'COD (KC)/P&T (MS)', 'faculty': 'KC,MS'},
        {'time': '11.35-12.25', 'subject': 'COD (KC)/P&T (MS)', 'faculty': 'KC,MS'},
        {'time': '1.25-2.15', 'subject': 'LIB (PV)', 'faculty': 'PV'},
        {'time': '2.15-3.05', 'subject': 'COUN (MP)', 'faculty': 'MP'},
        {'time': '3.25-4.15', 'subject': 'SPD (PV)', 'faculty': 'PV'},
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
  String _selectedSection = 'A';
  bool _isEditing = true;
  Map<int, Set<int>> _selectedPeriods = {};

  final List<String> days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _initializeSelectedPeriods();
  }

  void _initializeSelectedPeriods() {
    final newSelection = <int, Set<int>>{};
    for (int i = 0; i < days.length; i++) {
      newSelection[i] = <int>{};
    }
    // Only set state if there's a change to prevent unnecessary rebuilds on hot reload
    if (_selectedPeriods.isEmpty || _selectedPeriods != newSelection) {
      setState(() {
        _selectedPeriods = newSelection;
      });
    }
  }

  Map<String, int> _getScheduleMetrics() {
    int totalPeriods = 0;
    int selectedPeriodsCount = 0;
    final currentSchedule = timetableData[_selectedSection]!['schedule'] as Map<String, List<Map<String, dynamic>>>;

    for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
      String day = days[dayIndex];
      List<Map<String, dynamic>>? periods = currentSchedule[day];

      if (periods != null) {
        final availablePeriodsIndices = periods.asMap().entries
            .where((entry) => entry.value['subject'] != 'Break/Free' && entry.value['time'] != 'N/A')
            .map((entry) => entry.key);
        totalPeriods += availablePeriodsIndices.length;

        final selectedIndices = _selectedPeriods[dayIndex] ?? <int>{};
        selectedPeriodsCount += selectedIndices.intersection(availablePeriodsIndices.toSet()).length;
      }
    }
    return {'total': totalPeriods, 'selected': selectedPeriodsCount};
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {}
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _togglePeriodSelection(int dayIndex, int periodIndex) {
    if (!_isEditing) return;
    final day = days[dayIndex];
    final period = _getPeriodDetail(day, periodIndex);
    final isSelectable = period['subject'] != 'Break/Free' && period['time'] != 'N/A';
    if (isSelectable) {
      setState(() {
        // Toggle function from the extension is used here
        _selectedPeriods.putIfAbsent(dayIndex, () => {}).toggle(periodIndex);
      });
    }
  }

  void _submitTimetable() {
    Map<String, List<Map<String, String>>> facultySchedule = {};
    final metrics = _getScheduleMetrics();
    final selectedCount = metrics['selected'] ?? 0;
    final currentSection = timetableData[_selectedSection]!['section'] as String;
    final currentSchedule = timetableData[_selectedSection]!['schedule'] as Map<String, List<Map<String, dynamic>>>;

    for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
      String day = days[dayIndex];
      List<Map<String, String>> dailyPeriods = [];
      List<Map<String, dynamic>>? periods = currentSchedule[day];
      final selectedIndices = _selectedPeriods[dayIndex] ?? <int>{};

      for (int periodIndex in selectedIndices) {
        if (periods != null && periodIndex < periods.length) {
          final periodData = periods[periodIndex];
          if (periodData['subject'] != 'Break/Free' && periodData['time'] != 'N/A') {
            dailyPeriods.add({
              'time': periodData['time']?.toString() ?? 'N/A',
              'subject': periodData['subject']?.toString() ?? 'N/A',
              // IMPORTANT: The faculty code in the timetable data might be a comma-separated list.
              // We're returning the full list here, and the `parseScheduleMap` in home_screen will just use it.
              'faculty': periodData['faculty']?.toString() ?? '', 
              'section': currentSection,
            });
          }
        }
      }
      if (dailyPeriods.isNotEmpty) facultySchedule[day] = dailyPeriods;
    }

    if (context.mounted) {
      // Pass the fully structured data back to the HomeScreen
      Navigator.of(context).pop(facultySchedule); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timetable submitted successfully! Selected periods: $selectedCount')),
      );
    }
  }

  Map<String, dynamic> _getPeriodDetail(String day, int periodIndex) {
    final schedule = timetableData[_selectedSection]?['schedule'] as Map<String, dynamic>?;
    final dailyPeriods = schedule?[day] as List<Map<String, dynamic>>? ?? [];
    if (periodIndex >= 0 && periodIndex < dailyPeriods.length) {
      return dailyPeriods[periodIndex];
    }
    return {'time': 'N/A', 'subject': 'Break/Free', 'faculty': ''};
  }

  Widget _buildTimetableCell(int dayIndex, int periodIndex) {
    final day = days[dayIndex];
    final period = _getPeriodDetail(day, periodIndex);
    final isSelected = _selectedPeriods[dayIndex]?.contains(periodIndex) ?? false;
    final Color darkGreen = Colors.green.shade700;
    final Color lightGreenShade = Colors.green.shade50;
    final isSelectable = period['subject'] != 'Break/Free' && period['time'] != 'N/A';

    Color cardColor = isSelected ? lightGreenShade : Colors.white;
    if (!_isEditing && !isSelected) cardColor = Colors.grey.shade100;

    BoxDecoration cardDecoration = BoxDecoration(
      color: cardColor,
      border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300, width: isSelected ? 1.5 : 0.5),
      borderRadius: BorderRadius.circular(4),
      boxShadow: isSelected && _isEditing ? [BoxShadow(color: darkGreen.withOpacity(0.2), blurRadius: 3, offset: const Offset(0, 1))] : null,
    );

    String subjectText = period['subject']?.toString() ?? 'N/A';
    String facultyCode = period['faculty']?.toString().isEmpty == true ? 'N/A' : period['faculty']!.toString();
    final textColor = isSelectable ? (isSelected ? darkGreen : Colors.black87) : Colors.grey.shade500;

    return InkWell(
      onTap: (_isEditing && isSelectable) ? () => _togglePeriodSelection(dayIndex, periodIndex) : null,
      child: Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: cardDecoration,
        constraints: const BoxConstraints(minHeight: 70.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(subjectText, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(facultyCode == 'N/A' ? '' : '($facultyCode)', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: textColor.withOpacity(0.7))),
            if (isSelected) Icon(Icons.check_circle_outline, size: 14, color: darkGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildFullTimetableTable() {
    final baseSchedule = (timetableData[_selectedSection] ?? timetableData['A'])!['schedule'] as Map<String, List<Map<String, dynamic>>>;
    final timeSlots = baseSchedule[days.first]?.map((p) => p['time'] as String).toList() ?? [];

    if (timeSlots.isEmpty) return const Center(child: Text('Timetable data is unavailable.'));

    List<TableRow> tableRows = [];

    tableRows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.indigo.shade100),
        children: [
          Container(padding: const EdgeInsets.all(8.0), alignment: Alignment.center, child: const Text('Time', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
          ...days.map((day) => Container(padding: const EdgeInsets.all(8.0), alignment: Alignment.center, child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)))),
        ],
      ),
    );

    for (int periodIndex = 0; periodIndex < timeSlots.length; periodIndex++) {
      tableRows.add(
        TableRow(
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(color: Colors.indigo.shade50, border: Border.all(color: Colors.grey.shade300, width: 0.5)),
              alignment: Alignment.center,
              constraints: const BoxConstraints(minHeight: 70.0),
              child: Text(timeSlots[periodIndex], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.indigo)),
            ),
            ...List.generate(days.length, (dayIndex) => _buildTimetableCell(dayIndex, periodIndex)),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: Colors.indigo.shade600, borderRadius: BorderRadius.circular(8)),
              child: Text('I MCA - $_selectedSection Timetable\nAdvisor: ${timetableData[_selectedSection]!['advisor']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(_isEditing ? 'Tap cells to select periods. Fix selection to submit.' : 'View Mode. Scroll right to see all days.', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54)),
            ),
            const SizedBox(height: 5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(100.0),
                columnWidths: const {0: FixedColumnWidth(80.0)},
                border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
                children: tableRows,
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
    final metrics = _getScheduleMetrics();
    final totalPeriods = metrics['total'] ?? 0;
    final selectedCount = metrics['selected'] ?? 0;
    final freeCount = totalPeriods - selectedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.facultyName.split(' ')[0]}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
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
              items: <String>['A', 'B'].map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(value: value, child: Text('Section $value'))).toList(),
            ),
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.lock_open : Icons.lock, color: _isEditing ? Colors.amberAccent : Colors.white),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'Selection is now enabled (Edit Mode).' : 'Selection is now fixed (View Mode).'), duration: const Duration(seconds: 1)));
            },
            tooltip: _isEditing ? 'Fix Selection' : 'Edit Selection',
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context), tooltip: 'Logout'),
        ],
      ),
      body: _buildFullTimetableTable(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Available: $totalPeriods', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text('Selected: $selectedCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                  Text('Remaining: $freeCount', style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedCount > 0 ? _submitTimetable : null,
                icon: const Icon(Icons.send),
                label: Text(selectedCount > 0 ? 'SUBMIT TIMETABLE ($selectedCount Periods)' : 'Select Periods to Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}