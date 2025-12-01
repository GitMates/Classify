import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// 1. Import the CommunityScreen for navigation
import 'community_screen.dart';

// Import the RequestScreen
import 'request_screen.dart';

// Global Firebase instances
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

// Hardcoded timetable data (Sections A and B)
const Map<String, Map<String, dynamic>> timetableData = {
  'A': {
    'section': 'I MCA - A',
    'advisor': ' | Dr.K.Chitra & Ms.P.Dhar  Ms.P.Dharanisri',
    'schedule': {
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'CP', 'faculty': 'SH,TK'},
        {'time': '2.15-3.05', 'subject': 'CP', 'faculty': 'SH,TK'},
        {'time': '3.25-4.15', 'subject': 'CP', 'faculty': 'SH,TK'},
      ],
      'Tue': [
        {'time': '8.45-9.35', 'subject': 'DBT', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'SE', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'AM', 'faculty': 'AM'},
        {'time': '1.25-2.15', 'subject': 'OS (PD)/P&T (PV)', 'faculty': 'PD/PV'},
        {'time': '2.15-3.05', 'subject': 'DSA', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'PSP', 'faculty': ''},
      ],
      'Wed': [
        {'time': '8.45-9.35', 'subject': 'AM', 'faculty': 'AM'},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'MP-I', 'faculty': 'KC'},
        {'time': '2.15-3.05', 'subject': 'MP-I', 'faculty': 'KC'},
        {'time': '3.25-4.15', 'subject': 'MP-I', 'faculty': 'KC'},
      ],
      'Thu': [
        {'time': '8.45-9.35', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT Lab CC1', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'PSP (T)', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'PSP (T)', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'SE', 'faculty': ''},
      ],
      'Fri': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC1', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'AM', 'faculty': 'AM'},
        {'time': '1.25-2.15', 'subject': 'COD (KC)/P&T (PV)', 'faculty': 'KC/PV'},
        {'time': '2.15-3.05', 'subject': 'PSP', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'Portal (CC1)', 'faculty': ''},
      ],
      'Sat': [
        {'time': '8.45-9.35', 'subject': 'OS (PD)/P&T (TK)', 'faculty': 'PD/TK'},
        {'time': '9.35-10.25', 'subject': 'OS (PD)/P&T (TK)', 'faculty': 'PD/TK'},
        {'time': '10.45-11.35', 'subject': 'COD (KC)/P&T (SH)', 'faculty': 'KC/SH'},
        {'time': '11.35-12.25', 'subject': 'COD (KC)/P&T (SH)', 'faculty': 'KC/SH'},
        {'time': '1.25-2.15', 'subject': 'COUN', 'faculty': 'SH'},
        {'time': '2.15-3.05', 'subject': 'SPD', 'faculty': 'MJ'},
        {'time': '3.25-4.15', 'subject': 'LIB', 'faculty': 'MJ'},
      ],
      'Sun': [], // Explicitly empty/excluded
    },
  },
  'B': {
    'section': 'I MCA - B',
    'advisor': 'Ms.T.Kalpana & Mr.S.B.Karthikeyan',
    'schedule': {
      'Mon': [
        {'time': '8.45-9.35', 'subject': 'DSA', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'AM', 'faculty': 'AM'},
        {'time': '10.45-11.35', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'CP (PV,MP)', 'faculty': 'PV/MP'},
        {'time': '2.15-3.05', 'subject': 'SE', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'CP', 'faculty': 'PV/MP'},
      ],
      'Tue': [
        {'time': '8.45-9.35', 'subject': 'DBT', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DSA', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'SE', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DBT Lab CC2', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'OS (PD)/P&T (SBK)', 'faculty': 'PD/SBK'},
        {'time': '2.15-3.05', 'subject': 'MP-I (CC2)', 'faculty': 'SBK'},
        {'time': '3.25-4.15', 'subject': 'DSA', 'faculty': ''},
      ],
      'Wed': [
        {'time': '8.45-9.35', 'subject': 'SE', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'AM', 'faculty': 'AM'},
        {'time': '11.35-12.25', 'subject': 'PSP', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'MP-I', 'faculty': 'SBK'},
        {'time': '2.15-3.05', 'subject': 'MP-I', 'faculty': 'SBK'},
        {'time': '3.25-4.15', 'subject': 'MP-I', 'faculty': 'SBK'},
      ],
      'Thu': [
        {'time': '8.45-9.35', 'subject': 'DBT Lab CC2', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DBT Lab CC2', 'faculty': ''},
        {'time': '10.45-11 Safe', 'subject': 'PSP (T)', 'faculty': ''},
        {'time': '11.35-12.25', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'DSA', 'faculty': ''},
        {'time': '2.15-3.05', 'subject': 'DBT', 'faculty': ''},
        {'time': '3.25-4.15', 'subject': 'SE', 'faculty': ''},
      ],
      'Fri': [
        {'time': '8.45-9.35', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '9.35-10.25', 'subject': 'DSA Lab CC2', 'faculty': ''},
        {'time': '10.45-11.35', 'subject': 'AM', 'faculty': 'AM'},
        {'time': '11.35-12.25', 'subject': 'PSP', 'faculty': ''},
        {'time': '1.25-2.15', 'subject': 'COD (KC)/P&T (PV)', 'faculty': 'KC/PV'},
        {'time': '2.15-3.05', 'subject': 'COD (KC)/P&T (MS)', 'faculty': 'KC/MS'},
        {'time': '3.25-4.15', 'subject': 'Portal (CC2)', 'faculty': ''},
      ],
      'Sat': [
        {'time': '8.45-9.35', 'subject': 'OS (PD)/P&T (TKL)', 'faculty': 'PD/TKL'},
        {'time': '9.35-10.25', 'subject': 'OS (PD)/P&T (SBK)', 'faculty': 'PD/SBK'},
        {'time': '10.45-11.35', 'subject': 'COD (KC)/P&T (MS)', 'faculty': 'KC/MS'},
        {'time': '11.35-12.25', 'subject': 'COD (KC)/P&T (MS)', 'faculty': 'KC/MS'},
        {'time': '1.25-2.15', 'subject': 'COUN', 'faculty': 'MP'},
        {'time': '2.15-3.05', 'subject': 'LIB', 'faculty': 'PV'},
        {'time': '3.25-4.15', 'subject': 'SPD', 'faculty': 'PV'},
      ],
      'Sun': [], // Explicitly empty/excluded
    },
  },
};

// PeriodToSubstitute is defined in request_screen.dart and reused here.
// The class declaration was removed to avoid having two different types with the same name
// across files; keep using the imported PeriodToSubstitute from request_screen.dart.

// -----------------------------------------------------------------------------
class TimeTableScreen extends StatefulWidget {
  final String facultyName;
  const TimeTableScreen({super.key, required this.facultyName});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  Map<String, List<Map<String, String>>> _currentSchedule = {};
  Map<String, Map<String, List<Map<String, String>>>> _savedSchedules = {};
  Map<String, String> _periodReminders = {};
  bool _isLoading = true;
  bool _isEditing = false;
  String _selectedSectionKey = 'A';
  List<String> _periodTimes = [];
  static const List<String> _sectionKeys = ['A', 'B'];
  static const List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  // REMOVED: bool _isFabExpanded = false;

  // Using email as the unique ID for faculty communication
  String get _facultyCode => _auth.currentUser?.email ?? 'UnknownFaculty';
  Map<String, dynamic> get _currentSectionData => timetableData[_selectedSectionKey]!;
  String get _currentSectionName => _currentSectionData['section'] as String;
  String get _currentAdvisorName => _currentSectionData['advisor'] as String;

  @override
  void initState() {
    super.initState();
    _initializeDefaultSchedule();
    _loadFacultyTimetable();
  }

  void _changeSection(String? newKey) {
    if (newKey == null || newKey == _selectedSectionKey) return;
    if (_isEditing) {
      _showSnackBar('Please submit or discard changes before switching sections.', Colors.red);
      return;
    }
    _savedSchedules[_selectedSectionKey] = _currentSchedule;
    setState(() {
      _selectedSectionKey = newKey;
      _initializeDefaultSchedule();
    });
    _loadFacultyTimetable();
  }

  void _initializeDefaultSchedule() {
    final scheduleData = timetableData[_selectedSectionKey]!['schedule'];
    _currentSchedule = (_allDays.map((day) {
      final periods = scheduleData[day] ?? [];
      return MapEntry(
        day,
        (periods as List).map((p) => Map<String, String>.from(p as Map)).toList(),
      );
    }).where((e) => e.value.isNotEmpty).toList())
        .fold({}, (map, entry) => map..[entry.key] = entry.value);

    if (_savedSchedules.containsKey(_selectedSectionKey)) {
      _applySavedSchedule(_savedSchedules[_selectedSectionKey]!);
    }
    _periodTimes = _extractPeriodTimes(_currentSchedule);
  }

  List<String> _extractPeriodTimes(Map<String, List<Map<String, String>>> schedule) {
    if (schedule.isEmpty || schedule.values.isEmpty) return [];
    final populatedDays = schedule.values.where((list) => list.isNotEmpty).toList();
    if (populatedDays.isEmpty) return [];
    final longestDay = populatedDays.reduce((a, b) => a.length > b.length ? a : b);
    return longestDay.map((p) => p['time']!).toList();
  }

  // MODIFIED: This function now preserves assignments made by the current faculty
  // to implement the permanent "freeze" feature. It also restores reminders.
  void _applySavedSchedule(Map<String, List<Map<String, String>>> saved) {
    // Clear reminders map, as it will be rebuilt from the loaded schedule.
    _periodReminders = {};
    saved.forEach((day, savedPeriods) {
      final currentPeriods = _currentSchedule[day];
      if (currentPeriods != null) {
        for (int i = 0; i < currentPeriods.length && i < savedPeriods.length; i++) {
          final savedPeriod = savedPeriods[i];
          final facultyCode = savedPeriod['faculty'] ?? '';
          final reminderText = savedPeriod['reminder'] ?? '';

          if (facultyCode.isNotEmpty) {
            // RESTORE assignments made by ANY faculty (including me)
            currentPeriods[i]['faculty'] = facultyCode;
            currentPeriods[i]['section'] = savedPeriod['section'] ?? _currentSectionName;

            if (reminderText.isNotEmpty && facultyCode == _facultyCode) {
              // Only restore the reminder if it belongs to the current faculty
              final periodTime = currentPeriods[i]['time']!;
              final reminderKey = '${day}_${periodTime}_$_selectedSectionKey';
              _periodReminders[reminderKey] = reminderText;
            }
          } else {
            // Period was empty, ensure the current one is also cleared
            currentPeriods[i]['faculty'] = '';
            currentPeriods[i].remove('section');
          }
        }
      }
    });
  }

  Future<void> _loadFacultyTimetable() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) print('Warning: User not authenticated.');
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await _firestore.collection('faculties').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _savedSchedules = {};
        for (final key in _sectionKeys) {
          if (data.containsKey('timetable_$key')) {
            final storedSection = data['timetable_$key'] as Map<String, dynamic>;
            _savedSchedules[key] = storedSection.map(
              (day, periods) => MapEntry(
                day,
                (periods as List).map((p) => Map<String, String>.from(p as Map)).toList(),
              ),
            );
          }
        }

        _initializeDefaultSchedule();

        // MODIFIED SNACKBAR MESSAGE
        _showSnackBar(
            'Timetable loaded. All previous assignments (yours and others) have been restored.',
            Colors.blue);
      } else {
        _showSnackBar('No saved data found. Using default timetable.', Colors.orange);
      }
      setState(() {
        _periodTimes = _extractPeriodTimes(_currentSchedule);
      });
    } catch (e) {
      if (kDebugMode) print('Error loading timetable: $e');
      _showSnackBar('Error loading data. Using default.', Colors.orange);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleAssignment(String day, int periodIndex) {
    if (_isLoading) return;
    final period = _currentSchedule[day]![periodIndex];
    final currentFaculty = period['faculty'];
    setState(() {
      _isEditing = true;
      if (currentFaculty == _facultyCode) {
        // Deselect/Clear the period (Self-assigned periods only)
        period['faculty'] = '';
        period.remove('section');
        period.remove('reminder');
        _periodReminders.remove('${day}_${period['time']}_$_selectedSectionKey');
      } else if (currentFaculty == null || currentFaculty.isEmpty) {
        // Select/Assign the period
        period['faculty'] = _facultyCode;
        period['section'] = _currentSectionName;
      } else {
        // Period assigned to someone else
        _showSnackBar('Period already assigned to $currentFaculty.', Colors.red);
        _isEditing = false;
      }
    });
  }

  List<Map<String, String>> _extractAssignedPeriods(
      String facultyCode, Map<String, Map<String, List<Map<String, String>>>> allSchedules) {
    final List<Map<String, String>> assignedList = [];
    allSchedules.forEach((sectionKey, schedule) {
      final sectionName = timetableData[sectionKey]!['section'] as String;
      schedule.forEach((day, periods) {
        for (var period in periods) {
          if (period['faculty'] == facultyCode) {
            final periodTime = period['time']!;
            final reminderKey = '${day}_${periodTime}_$sectionKey';
            // Use the reminder from the state variable if available (for unsaved changes),
            // otherwise use the saved one from the period map.
            final reminderText = _periodReminders[reminderKey] ?? period['reminder'] ?? '';
            assignedList.add({
              'day': day,
              'time': periodTime,
              'subject': period['subject'] ?? 'N/A',
              'faculty': facultyCode,
              'section': sectionName,
              'reminder': reminderText,
            });
          }
        }
      });
    });
    return assignedList;
  }

  void _submitAndGoHome() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    final navigateBack = () {
      if (mounted) {
        // Pass ALL assigned periods back to the caller (likely home_screen.dart)
        final assigned = _extractAssignedPeriods(_facultyCode, _savedSchedules);
        Navigator.pop(context, assigned);
      }
    };

    if (user == null) {
      _showSnackBar('Not authenticated. Changes not saved.', Colors.red);
      navigateBack();
      return;
    }

    try {
      _savedSchedules[_selectedSectionKey] = _currentSchedule;
      for (final day in _currentSchedule.keys) {
        for (final period in _currentSchedule[day]!) {
          if (period['faculty'] == _facultyCode) {
            final reminderKey = '${day}_${period['time']}_$_selectedSectionKey';
            final reminderText = _periodReminders[reminderKey];
            if (reminderText != null && reminderText.isNotEmpty) {
              period['reminder'] = reminderText;
            } else {
              period.remove('reminder');
            }
          } else {
            // Ensure only my assignments carry a reminder field in Firestore
            period.remove('reminder');
          }
        }
      }

      final Map<String, dynamic> firestoreData = {};
      _savedSchedules.forEach((key, value) {
        firestoreData['timetable_$key'] = value;
      });
      await _firestore
          .collection('faculties')
          .doc(user.uid)
          .set(firestoreData, SetOptions(merge: true));
      _showSnackBar('Timetable saved successfully!', Colors.green);
    } catch (e) {
      if (kDebugMode) print('Error saving timetable: $e');
      _showSnackBar('Error saving timetable. Please try again.', Colors.red);
    } finally {
      setState(() => _isLoading = false);
      _isEditing = false;
      navigateBack();
    }
  }

  Future<void> _buildRemainderDialog() async {
    // REMOVED: setState(() => _isFabExpanded = false);

    final assignedPeriods = _currentSchedule.entries
        .expand((entry) {
          final day = entry.key;
          return entry.value
              .where((period) => period['faculty'] == _facultyCode)
              .map((period) {
            final reminderKey = '${day}_${period['time']}_$_selectedSectionKey';
            return {
              'day': day,
              'time': period['time']!,
              'subject': period['subject']!,
              'key': reminderKey,
              // Get initial reminder from the state variable _periodReminders
              'initialReminder': _periodReminders[reminderKey] ?? '',
            };
          });
        })
        .toList()
      ..sort((a, b) =>
          _allDays.indexOf(a['day'] as String).compareTo(_allDays.indexOf(b['day'] as String)));

    if (assignedPeriods.isEmpty) {
      _showSnackBar('You must assign periods before adding reminders.', Colors.orange);
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add/Edit Reminders'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: assignedPeriods.length,
              itemBuilder: (context, index) {
                final period = assignedPeriods[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text('${period['subject']} (${period['time']})'),
                      subtitle: Text('${period['day']} - Section $_selectedSectionKey'),
                      trailing: const Icon(Icons.edit, color: Colors.indigo),
                      onTap: () async {
                        await _editPeriodReminder(
                          period['day'] as String,
                          period['time'] as String,
                          period['subject'] as String,
                          period['key'] as String,
                          period['initialReminder'] as String,
                        );
                        Navigator.of(context).pop();
                        _buildRemainderDialog();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPeriodReminder(
      String day, String time, String subject, String key, String initialReminder) async {
    TextEditingController controller = TextEditingController(text: initialReminder);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reminder for $subject on $day'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'e.g., Homework: Read chapter 5, Project: Demo tomorrow',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newReminder = controller.text.trim();
                setState(() {
                  if (newReminder.isNotEmpty) {
                    _periodReminders[key] = newReminder;
                  } else {
                    _periodReminders.remove(key);
                  }
                  _isEditing = true;
                });
                _showSnackBar('Reminder saved for $subject!', Colors.green);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Handles the navigation to RequestScreen
  void _navigateToRequestSubstitute() {
    // REMOVED: setState(() => _isFabExpanded = false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BuildPeriodSelectionSheet(
        schedule: _currentSchedule,
        currentSectionName: _currentSectionName,
        onPeriodSelected: (day, time, subject) {
          final period = PeriodToSubstitute(
            day: day,
            timeSlot: time,
            subject: subject,
            section: _currentSectionName,
            requesterFacultyId: _facultyCode,
            requesterFacultyName: widget.facultyName,
          );

          Navigator.pop(context); // Close the bottom sheet

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RequestScreen(period: period),
            ),
          );
        },
      ),
    );
  }

  // MODIFIED: Action Buttons method to align with the user's image request
  Widget _buildActionButtons() {
    // Define a common style for the Remainder and Request buttons
    final buttonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      backgroundColor: Colors.white, // Light background
      foregroundColor: Colors.indigo.shade800,
      side: BorderSide(color: Colors.indigo.shade300),
      elevation: 2,
    );

    // Define the style for the central Submit button
    final submitButtonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      backgroundColor: Colors.indigo.shade700, // Primary color
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      elevation: 4,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the main column content
        children: [
          // Row for Remainder and Request
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the two buttons
            children: [
              // Remainder Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: _buildRemainderDialog,
                    style: buttonStyle,
                    child: const Text('Remainder'),
                  ),
                ),
              ),

              // Request Substitute Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: _navigateToRequestSubstitute,
                    style: buttonStyle,
                    child: const Text('Request'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Space between the row and the submit button

          // Submit Button (Center aligned under the two buttons)
          ElevatedButton(
            onPressed: _submitAndGoHome,
            style: submitButtonStyle,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timetable Selection',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
          ),
          const SizedBox(height: 5),
          Text(
            'Faculty: ${widget.facultyName}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            'Advisor: $_currentAdvisorName',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedSectionKey,
            items: _sectionKeys.map((key) {
              return DropdownMenuItem(
                value: key,
                child: Text('Section ${timetableData[key]!['section']}'),
              );
            }).toList(),
            onChanged: _changeSection,
            decoration: InputDecoration(
              labelText: 'Select Section',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableTable() {
    final days = _allDays;
    final columnWidths = <int, TableColumnWidth>{0: const FixedColumnWidth(100)};
    for (var i = 1; i <= days.length; i++) {
      columnWidths[i] = const FixedColumnWidth(100);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: columnWidths,
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(color: Colors.indigo.shade50),
              children: [
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ),
                ...days.map((day) => TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    )),
              ],
            ),
            // Data Rows
            ..._periodTimes.asMap().entries.map((timeEntry) {
              final int periodIndex = timeEntry.key;
              final String time = timeEntry.value;
              return TableRow(
                children: [
                  TableCell(
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      color: Colors.indigo.shade50,
                      alignment: Alignment.center,
                      child: Text(time,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  ...days.map((day) {
                    final dayPeriods = _currentSchedule[day];
                    if (dayPeriods == null || dayPeriods.length <= periodIndex) {
                      return const TableCell(child: SizedBox(height: 50));
                    }
                    final period = dayPeriods[periodIndex];
                    final String subject = period['subject'] ?? '';
                    final String faculty = period['faculty'] ?? '';
                    final bool isAssignedToMe = faculty == _facultyCode;
                    final bool isAssignedToOther = faculty.isNotEmpty && !isAssignedToMe;

                    final Color cellColor = isAssignedToMe ? Colors.green.shade700 : Colors.white;
                    final Color textColor = isAssignedToMe ? Colors.white : Colors.black87;

                    return TableCell(
                      child: InkWell(
                        onTap: () => _toggleAssignment(day, periodIndex),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          color: cellColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                subject,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isAssignedToOther ? Colors.red.shade900 : textColor,
                                ),
                              ),
                              if (isAssignedToOther)
                                Text(
                                  faculty,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 8, color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Assignment'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.people_alt_rounded),
          color: Colors.white,
          onPressed: () {
            try {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommunityScreen(),
                ),
              );
            } catch (e) {
              if (kDebugMode) {
                print(
                    'Error: Could not navigate to CommunityScreen. Ensure community_screen.dart is in the same directory a');
              }
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const Divider(),
                  _buildTimetableTable(),
                  _buildActionButtons(), // Action buttons are now here
                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: null, // Removed the FAB Speed Dial
    );
  }
}

// ----------------------------------------------------------------------
// HELPER WIDGET: Period Selection Sheet for Substitution Request
// ----------------------------------------------------------------------
class _BuildPeriodSelectionSheet extends StatelessWidget {
  final Map<String, List<Map<String, String>>> schedule;
  final String currentSectionName;
  final Function(String day, String time, String subject) onPeriodSelected;

  const _BuildPeriodSelectionSheet({
    required this.schedule,
    required this.currentSectionName,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final assignedPeriods = schedule.entries
        .expand((entry) {
          final day = entry.key;
          return entry.value
              .where((period) => (period['faculty'] ?? '').isNotEmpty)
              .map((period) => {
                    'day': day,
                    'time': period['time']!,
                    'subject': period['subject']!,
                    'faculty': period['faculty']!,
                    'section': period['section']!,
                  });
        });

    final facultyCode = FirebaseAuth.instance.currentUser?.email ?? 'UnknownFaculty';
    final myPeriods = assignedPeriods
        .where((p) => p['faculty'] == facultyCode && p['section'] == currentSectionName)
        .toList();

    if (myPeriods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'You have no assigned periods in this section to request a substitute for.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Period to Request Substitute',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: myPeriods.length,
                itemBuilder: (context, index) {
                  final period = myPeriods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: ListTile(
                      title: Text(
                        '${period['subject']} (${period['time']})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${period['day']} - ${period['section']}'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.green),
                      onTap: () {
                        onPeriodSelected(
                          period['day']!,
                          period['time']!,
                          period['subject']!,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}