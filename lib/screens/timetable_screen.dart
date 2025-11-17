import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For diagnostic logging

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
        {'time': '1.25-2.15', 'subject': 'DSA', 'faculty': ''},
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


// --- 2. TimeTableScreen StatefulWidget (User's Code) ---
class TimeTableScreen extends StatefulWidget {
  final String facultyName;
  final String initialSection; // Added to receive the currently selected section from Home

  const TimeTableScreen({super.key, required this.facultyName, this.initialSection = 'A'});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  String _selectedSection = 'A'; // Tracks the section currently being viewed/edited
  bool _isEditing = true; // Toggle edit mode
  Map<int, Set<int>> _selectedPeriods = {}; 
  String? _userId;
  StreamSubscription<DocumentSnapshot>? _subscription;
  bool _isLoading = true; 

  // Indices correspond to the Data Row (0=Mon, 1=Tue, ..., 5=Sat)
  final List<String> days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    // Use the section passed from the Home Screen
    _selectedSection = widget.initialSection; 
    _initializeAuthAndLoadData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // --- Firebase/Firestore Logic ---
  DocumentReference get _timetableRef => _firestore
      .collection('artifacts')
      .doc(__app_id)
      .collection('users')
      .doc(_userId)
      .collection('selectedTimetable')
      .doc(_selectedSection); // Uses the current selected section

  Future<void> _initializeAuthAndLoadData() async {
    try {
      if (_auth.currentUser == null) {
        if (__initial_auth_token.isNotEmpty) {
          await _auth.signInWithCustomToken(__initial_auth_token);
        } else {
          await _auth.signInAnonymously();
        }
      }
      
      if (!mounted) return;

      setState(() {
        _userId = _auth.currentUser?.uid;
      });

      if (_userId != null) {
        _loadSelectedPeriods();
      } else {
        if (kDebugMode) print('Error: Could not determine user ID.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) print('Firebase Auth Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Reloads selected periods when section changes or on init
  void _loadSelectedPeriods() {
    _subscription?.cancel();
    
    // Set initial state to empty while loading new data
    if (mounted) {
      setState(() {
        _selectedPeriods = {};
        _isLoading = true; 
      });
    }
    
    if (_userId != null) {
      // Start listening to the selected periods for the currently selected section
      _subscription = _timetableRef.snapshots().listen((snapshot) {
        if (!mounted) return;
        
        final Map<int, Set<int>> loadedPeriods = {};
        for (int i = 0; i < days.length; i++) {
          loadedPeriods[i] = <int>{}; // Initialize all days as empty sets
        }

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          
          for (int i = 0; i < days.length; i++) {
            final dayName = days[i];
            final List<dynamic>? periods = data[dayName];
            
            if (periods != null) {
              // Convert List<dynamic> to Set<int>
              loadedPeriods[i] = Set<int>.from(periods.map((e) => e as int));
            }
          }

          if (kDebugMode) print('Timetable loaded for Section $_selectedSection. Periods selected: ${loadedPeriods.values.map((s) => s.length).reduce((a, b) => a + b)} periods.');
        } else {
            if (kDebugMode) print('No saved timetable found for Section $_selectedSection.');
        }

        setState(() {
          _selectedPeriods = loadedPeriods;
          _isLoading = false;
        });
      }, onError: (error) {
        if (kDebugMode) print('Error listening to timetable: $error');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading data: $error')),
          );
        }
      });
    } else {
        setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTimetableToFirestore(Map<String, List<int>> data) async {
    if (_userId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication not ready. Cannot save.')),
          );
        }
      return;
    }
    
    try {
      // Use SetOptions(merge: false) to overwrite only the selected sections, 
      // ensuring that if the user deselects everything, the entry is cleared/replaced.
      await _timetableRef.set(data, SetOptions(merge: false));
      if (kDebugMode) print('Timetable saved successfully for Section $_selectedSection.');
    } catch (e) {
      if (kDebugMode) print('Error saving timetable: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save timetable: $e')),
        );
      }
    }
  }
  
  // --- Core Logic ---

  void _onSectionChanged(String? newSection) {
    if (newSection != null && newSection != _selectedSection) {
      setState(() {
        _selectedSection = newSection;
      });
      _loadSelectedPeriods(); // Load data for the newly selected section
    }
  }

  void _togglePeriodSelection(int dayIndex, int periodIndex) {
    if (!_isEditing) return;

    setState(() {
      final daySet = _selectedPeriods.putIfAbsent(dayIndex, () => <int>{});
      if (daySet.contains(periodIndex)) {
        daySet.remove(periodIndex);
      } else {
        daySet.add(periodIndex);
      }
    });
  }

  // Renamed to follow user request: "click the sumbit button it display the home_screen.dart"
  void _submitAndGoHome() async {
    if (_isEditing) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please switch to View Mode before submitting.')),
        );
      }
      return;
    }

    // 1. Prepare data for Firestore (Map<String, List<int>>)
    final Map<String, List<int>> firestoreData = {};
    for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final day = days[dayIndex];
      // Only save days that have selections
      final periods = _selectedPeriods[dayIndex];
      if (periods != null && periods.isNotEmpty) {
        firestoreData[day] = periods.toList();
      }
    }

    // 2. Save to Firestore
    // Note: The saving is performed even in View Mode before returning home, as required by the submit logic.
    await _saveTimetableToFirestore(firestoreData);

    // 3. Return to Home Screen, passing back the section that was just edited/saved
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Timetable saved! Returning to Home Screen (Section $_selectedSection).'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Pass back the section so HomeScreen can reload the correct data
      Navigator.of(context).pop(_selectedSection); 
    }
  }

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
    final isSelected = _selectedPeriods.containsKey(dayIndex) && _selectedPeriods[dayIndex]!.contains(periodIndex);
    
    // Period is selectable if it's not explicitly marked as a "Break/Free" in the data, 
    // or if the subject is not empty/placeholder.
    final isSelectable = !(period['subject']?.toString().toLowerCase().contains('break') ?? false) && 
                         !(period['subject']?.toString().toLowerCase().contains('free') ?? false) &&
                         (period['subject']?.toString().isNotEmpty ?? false);

    final Color primaryColor = Colors.indigo.shade600;
    final Color selectedColor = isSelectable ? Colors.green.shade50 : Colors.white;
    final Color unselectedColor = Colors.white;

    Color cardColor = unselectedColor;
    if (isSelected) {
      cardColor = selectedColor;
    } else if (!_isEditing) {
      cardColor = Colors.grey.shade100; // Grey out unselected cells in view mode
    }

    final textColor = isSelected
        ? primaryColor
        : (isSelectable ? Colors.black87 : Colors.grey.shade500);
    
    final borderColor = isSelected 
        ? primaryColor 
        : (_isEditing ? Colors.grey.shade300 : Colors.grey.shade200);

    final String subjectText = period['subject']?.toString() ?? 'N/A';
    final String facultyCode = (period['faculty']?.toString().isEmpty ?? true)
        ? ''
        : '(${period['faculty']})';

    return InkWell(
      onTap: (_isEditing && isSelectable)
          ? () => _togglePeriodSelection(dayIndex, periodIndex)
          : null,
      child: Container(
        // Using a fixed size for the table cells to ensure alignment
        width: 120, // Wider for landscape view
        height: 70, // Slightly reduced height
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected && _isEditing
              ? [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 3, offset: const Offset(0, 1))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              subjectText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (facultyCode.isNotEmpty)
              Text(
                facultyCode,
                style: TextStyle(fontSize: 10, color: textColor),
              ),
            if (isSelected && !_isEditing)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // --- UI Builder Methods ---

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? sectionDetails = timetableData[_selectedSection];
    final List<Map<String, dynamic>>? dailyPeriods = (sectionDetails?['schedule'] as Map<String, dynamic>?)?['Mon'] as List<Map<String, dynamic>>?;
    
    // Get all unique time slots for the header row
    final List<String> timeSlots = dailyPeriods?.map((p) => p['time'].toString()).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.facultyName}\'s Schedule Setup (${_selectedSection})'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
            tooltip: _isEditing ? 'Switch to View Mode' : 'Switch to Edit Mode',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switched to View Mode. Now you can submit your selection.')),
                );
              } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switched to Edit Mode. Tap classes to select them.')),
                );
              }
            },
          ),
          // Moved submit button to the bottom, but kept the Save icon here for quick saving if needed
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Quick Save Data',
            onPressed: () {
              // This is a quick save function, separate from the "Submit and Go Home" button below
              final Map<String, List<int>> firestoreData = {};
              for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
                final day = days[dayIndex];
                final periods = _selectedPeriods[dayIndex];
                if (periods != null && periods.isNotEmpty) {
                  firestoreData[day] = periods.toList();
                }
              }
              _saveTimetableToFirestore(firestoreData);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Section Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Class: ${sectionDetails?['section'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                      ),
                      DropdownButton<String>(
                        value: _selectedSection,
                        items: timetableData.keys.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Section $value'),
                          );
                        }).toList(),
                        onChanged: _onSectionChanged,
                        style: TextStyle(color: Colors.indigo.shade800, fontWeight: FontWeight.bold, fontSize: 16),
                        underline: Container(),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
                
                // --- Landscape/Table Timetable Grid ---
                Expanded(
                  // Use a ScrollView for both axes for full responsiveness
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Time Slot Header Row
                            Row(
                              children: [
                                // Corner cell spacer
                                const SizedBox(width: 120, height: 40), 
                                ...timeSlots.map((time) => Container(
                                  width: 120,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade100,
                                    border: Border.all(color: Colors.indigo.shade200, width: 0.5),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    // Split time for better fit
                                    time.replaceAll('-', '-\n'), 
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                    maxLines: 2,
                                  ),
                                )).toList(),
                              ],
                            ),

                            // 2. Day Rows
                            ...days.map((day) {
                              final dayIndex = days.indexOf(day);
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Day Name Column Header
                                  Container(
                                    width: 120,
                                    height: 72, // Matches cell height
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      border: Border.all(color: Colors.indigo.shade200, width: 0.5),
                                    ),
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo.shade900),
                                    ),
                                  ),
                                  // Period Cells for the Day
                                  ...List.generate(timeSlots.length, (periodIndex) {
                                    return _buildTimetableCell(dayIndex, periodIndex);
                                  }),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 3. Submit Button Section at the bottom
                Container(
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
                    onPressed: _submitAndGoHome,
                    icon: const Icon(Icons.send),
                    label: Text(
                      _isEditing ? 'Exit Edit Mode to Submit' : 'Submit Timetable & Go Home',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _isEditing ? Colors.grey : Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}