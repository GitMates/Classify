// main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// NOTE: In a real Flutter app, you would also need:
// import 'package:firebase_core/firebase_core.dart';
// But we will simulate the initialization using the global variables provided by the Canvas environment.

// --- Global Firebase Configuration (Simulated for Canvas) ---
// In a full Flutter app, you must call Firebase.initializeApp().
// The Canvas environment provides these variables for authentication and pathing:
const String __app_id = 'timetable-app-v1';
const String __initial_auth_token = ''; // Token for custom sign-in
// const String __firebase_config = '{}'; // Configuration object (simulated as already initialized)

// Initialize Firebase services using simulated instances.
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

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

// --- Placeholder for Imported HomeScreen ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen (Placeholder)'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login or continue to Timetable'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // For demonstration, navigate directly to TimeTableScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const TimeTableScreen(
                      facultyName: 'Sample Faculty Name',
                    ),
                  ),
                );
              },
              child: const Text('Go to Timetable Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. TimeTableScreen StatefulWidget (User's Code) ---
class TimeTableScreen extends StatefulWidget {
  final String facultyName;

  const TimeTableScreen({super.key, required this.facultyName});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  String _selectedSection = 'A'; // Default to Section A
  bool _isEditing = true; // Toggle edit mode
  // Stores selected periods as {dayIndex: {periodIndex, ...}}
  Map<int, Set<int>> _selectedPeriods = {}; 
  String? _userId;
  StreamSubscription<DocumentSnapshot>? _subscription;
  bool _isLoading = true; // Added loading state

  final List<String> days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _initializeAuthAndLoadData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // --- Firebase/Firestore Logic ---

  Future<void> _initializeAuthAndLoadData() async {
    // 1. Authenticate (using anonymous sign-in as fallback)
    try {
      if (__initial_auth_token.isNotEmpty) {
        await _auth.signInWithCustomToken(__initial_auth_token);
      } else {
        await _auth.signInAnonymously();
      }
      
      // Ensure the widget is still mounted before setting state/using context
      if (!mounted) return;

      setState(() {
        _userId = _auth.currentUser?.uid;
        _isLoading = false; 
      });

      if (_userId != null) {
        // Start listening to the selected periods for the default section
        _loadSelectedPeriods();
      } else {
        print('Error: Could not determine user ID.');
      }
    } catch (e) {
      print('Firebase Auth Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Updated Firestore path to use __app_id and users/{userId} for private data
  DocumentReference get _timetableRef => _firestore
      .collection('artifacts')
      .doc(__app_id)
      .collection('users')
      .doc(_userId)
      .collection('selectedTimetable')
      .doc(_selectedSection);

  // Initialize/reset selected periods and start listening to Firestore
  void _initializeSelectedPeriods() {
    // Cancel existing subscription if switching sections
    _subscription?.cancel();
    
    // Set initial state to empty while loading new data
    setState(() {
      _selectedPeriods = {};
      _isLoading = true; 
    });
    
    if (_userId != null) {
      _loadSelectedPeriods();
    } else {
       setState(() {
        _isLoading = false; 
      });
    }
  }

  // Load selected periods from Firestore in real-time
  void _loadSelectedPeriods() {
    _subscription = _timetableRef.snapshots().listen((snapshot) {
      if (!mounted) return;
      
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        
        final Map<int, Set<int>> loadedPeriods = {};
        for (int i = 0; i < days.length; i++) {
          final dayName = days[i];
          final List<dynamic>? periods = data[dayName];
          
          if (periods != null) {
            // Convert List<dynamic> (which contains ints/dynamic numbers) to Set<int>
            loadedPeriods[i] = Set<int>.from(periods.map((e) => e as int));
          } else {
            loadedPeriods[i] = <int>{};
          }
        }

        setState(() {
          _selectedPeriods = loadedPeriods;
          _isLoading = false;
        });
        print('Timetable loaded for Section $_selectedSection. Periods selected: $_selectedPeriods');
      } else {
        // If document doesn't exist, ensure local state is empty
        setState(() {
          _selectedPeriods = {};
          for (int i = 0; i < days.length; i++) {
            _selectedPeriods[i] = <int>{};
          }
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error listening to timetable: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $error')),
        );
      }
    });
  }

  Future<void> _saveTimetableToFirestore(Map<String, List<int>> data) async {
    if (_userId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication not ready. Cannot save.')),
        );
      return;
    }
    
    try {
      await _timetableRef.set(data, SetOptions(merge: false));
      print('Timetable saved successfully for Section $_selectedSection.');
    } catch (e) {
      print('Error saving timetable: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save timetable: $e')),
        );
      }
    }
  }

  // --- Core Logic ---

  // Logout handler
  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Toggle period selection
  void _togglePeriodSelection(int dayIndex, int periodIndex) {
    if (!_isEditing) return;

    setState(() {
      if (_selectedPeriods.containsKey(dayIndex) && _selectedPeriods[dayIndex]!.contains(periodIndex)) {
        _selectedPeriods[dayIndex]!.remove(periodIndex);
      } else {
        _selectedPeriods.putIfAbsent(dayIndex, () => <int>{}).add(periodIndex);
      }
    });
  }

  // Submit selected timetable - REMOVED NAVIGATION TO DASHBOARD
  void _submitTimetable() async {
    if (_isEditing) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please lock the selection (View Mode) before submitting.')),
        );
      }
      return;
    }

    // 1. Prepare data for Firestore (Map<String, List<int>>)
    final Map<String, List<int>> firestoreData = {};
    for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final day = days[dayIndex];
      // Only save days that have selections
      if (_selectedPeriods.containsKey(dayIndex) && _selectedPeriods[dayIndex]!.isNotEmpty) {
        firestoreData[day] = _selectedPeriods[dayIndex]!.toList();
      }
    }

    // 2. Save to Firestore
    await _saveTimetableToFirestore(firestoreData);

    // 3. Show success message (instead of navigating)
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your timetable has been successfully submitted and saved.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    // Stay on the current screen
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
    final isSelected = _selectedPeriods.containsKey(dayIndex) && _selectedPeriods[dayIndex]!.contains(periodIndex);
    final isSelectable = period['subject'] != 'Break/Free' && period['time'] != 'N/A';

    final Color darkGreen = Colors.green.shade700;
    final Color lightGreen = isSelected ? Colors.green.shade50 : Colors.white;

    Color cardColor = lightGreen;
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
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.check_circle_outline, size: 14, color: darkGreen),
              ),
          ],
        ),
      ),
    );
  }

  // Build full timetable table
  Widget _buildFullTimetableTable() {
    final scheduleA = timetableData['A']!['schedule'] as Map<String, List<Map<String, dynamic>>>;
    final timeSlots = scheduleA[days.first]?.map((p) => p['time'] as String).toList() ?? [];

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userId == null) {
      return const Center(child: Text('Authentication failed. Please check setup.'));
    }

    if (timeSlots.isEmpty || timetableData[_selectedSection] == null) {
      return Center(child: Text('Timetable data is unavailable for Section $_selectedSection.'));
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
                _isEditing ? 'TAP to select periods. Lock to submit.' : 'VIEW MODE. Unlock to edit.',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
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
                if (newValue != null) {
                  setState(() {
                    _selectedSection = newValue;
                  });
                  _initializeSelectedPeriods(); // Load new section data
                }
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isEditing
                        ? 'Selection is now enabled (Edit Mode).'
                        : 'Selection is now fixed (View Mode).'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
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
          icon: const Icon(Icons.send),
          label: Text(_isEditing ? 'Submit (Lock Selection First)' : 'Submit Timetable'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing ? Colors.grey : Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
          ),
        ),
      ),
    );
  }
}

// --- Main Application Entry Point ---

void main() {
  // NOTE: In a real Flutter environment, you would call:
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // We skip this since the environment simulates initialization via global variables.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faculty Timetable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      // Start the app directly on the Timetable screen for demonstration
      home: const TimeTableScreen(facultyName: 'Dr. John Doe'),
    );
  }
}