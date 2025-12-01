import 'package:flutter/material.dart';
import 'package:pooja/screens/profile_screen.dart';
import 'package:pooja/screens/timetable_screen.dart';
import 'package:pooja/screens/chat_screen.dart';
import 'package:pooja/screens/notify_screen.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// Firebase / Storage imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// PeriodNotification model is defined in notify_screen.dart to avoid duplicate
// type definitions across files; home_screen.dart imports notify_screen.dart
// so the shared type is already available.

// -----------------------------------------------------------------------------
// 0. DATA MODEL: Assignment Model
// -----------------------------------------------------------------------------
class Assignment {
  final String day;
  final String time; // e.g., "09:00 - 09:50"
  final String subject;
  final String facultyCode;
  final String section;
  final String reminder;

  Assignment({
    required this.day,
    required this.time,
    required this.subject,
    required this.facultyCode,
    required this.section,
    this.reminder = '',
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'time': time,
        'subject': subject,
        'facultyCode': facultyCode,
        'section': section,
        'reminder': reminder,
      };

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        day: json['day'] as String,
        time: json['time'] as String,
        subject: json['subject'] as String,
        facultyCode: json['facultyCode'] as String,
        section: json['section'] as String,
        reminder: json['reminder'] as String? ?? '',
      );

  DateTime get startTime {
    final parts = time.split(' - ');
    final timeString = parts.first.replaceAll('.', ':');
    final now = DateTime.now();
    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts.first);
      final minute = int.parse(timeParts.last);
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      // EDITED: Added debug print for safety check
      debugPrint('Warning: Failed to parse Assignment start time "$time". Error: $e');
      return DateTime.now().subtract(const Duration(hours: 1));
    }
  }

  DateTime get endTime {
    final parts = time.split(' - ');
    final timeString = parts.last.replaceAll('.', ':');
    final now = DateTime.now();
    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts.first);
      final minute = int.parse(timeParts.last);
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      // EDITED: Added debug print for safety check
      debugPrint('Warning: Failed to parse Assignment end time "$time". Error: $e');
      return DateTime.now().subtract(const Duration(hours: 1));
    }
  }

  bool get isCurrentPeriod {
    final now = DateTime.now();
    final currentDay = DateFormat('EEE').format(now);
    return currentDay == day && now.isAfter(startTime) && now.isBefore(endTime);
  }
}

// -----------------------------------------------------------------------------
// Parse timetable map from TimeTableScreen
// -----------------------------------------------------------------------------
List<Assignment> parseAssignedList(List<Map<String, String>> assignedPeriods) {
  return assignedPeriods.map((period) {
    return Assignment(
      day: period['day'] ?? 'N/A',
      time: period['time'] ?? 'N/A',
      subject: period['subject'] ?? 'N/A',
      facultyCode: period['faculty'] ?? 'N/A',
      section: period['section'] ?? 'I MCA',
      reminder: period['reminder'] ?? '',
    );
  }).toList();
}

// -----------------------------------------------------------------------------
// Firebase & Local Schedule Service
// -----------------------------------------------------------------------------
class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _scheduleKey = 'faculty_schedule_key';

  Future<void> saveSchedule(String facultyId, List<Assignment> schedule) async {
    final scheduleJson = schedule.map((a) => a.toJson()).toList();

    try {
      await _db.collection('facultySchedules').doc(facultyId).set({
        'schedule': scheduleJson,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving schedule: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scheduleKey, jsonEncode(scheduleJson));
  }

  Future<List<Assignment>> loadSchedule(String facultyId) async {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getString(_scheduleKey);

    if (localData != null) {
      final List<dynamic> jsonList = jsonDecode(localData);
      return jsonList.map((json) => Assignment.fromJson(json)).toList();
    }

    try {
      final doc = await _db.collection('facultySchedules').doc(facultyId).get();
      if (doc.exists) {
        final List<dynamic> jsonList = doc.data()!['schedule'];
        await prefs.setString(_scheduleKey, jsonEncode(jsonList));
        return jsonList.map((json) => Assignment.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    }

    return [];
  }
}

// -----------------------------------------------------------------------------
// SCHEDULE TIMELINE WIDGET
// -----------------------------------------------------------------------------
class VerticalTimeline extends StatefulWidget {
  final List<Assignment> assignments;
  final String totalHours;
  final List<String> daysToDisplay;

  const VerticalTimeline({
    super.key,
    required this.assignments,
    required this.totalHours,
    required this.daysToDisplay,
  });

  @override
  State<VerticalTimeline> createState() => _VerticalTimelineState();
}

class _VerticalTimelineState extends State<VerticalTimeline> {
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    // Set up a timer to trigger UI refresh every second for smooth animation
    _animationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 50, color: Colors.indigo.shade400),
            const SizedBox(height: 10),
            const Text(
              'No Timetable Approved Yet.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Use the Timetable icon to submit your schedule.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    final Map<String, List<Assignment>> assignmentsByDay = {};
    for (var a in widget.assignments) {
      assignmentsByDay.putIfAbsent(a.day, () => []).add(a);
    }

    assignmentsByDay.forEach((_, list) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    final List<String> sortedDays =
        widget.daysToDisplay.where(assignmentsByDay.containsKey).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approved Weekly Schedule',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            Text(
              'Total Teaching Load: ${widget.totalHours}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            const Divider(thickness: 2),
            if (sortedDays.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  ' All scheduled days for this week are complete!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ...sortedDays.map((day) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 8),
                    child: Text(
                      day.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                  ),
                  _buildDailyTimeline(assignmentsByDay[day]!),
                ],
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
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
        final isCurrent = assignment.isCurrentPeriod;
        final hasReminder = assignment.reminder.isNotEmpty;
        final isLast = index == dailyAssignments.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 25,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.green : Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: PeriodProgressIndicator(
                          assignment: assignment,
                          nextAssignment: dailyAssignments[index + 1],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${assignment.subject} (${assignment.time})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.green.shade800 : Colors.black87,
                        ),
                      ),
                      Text(
                        'Section: ${assignment.section}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      if (hasReminder) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Reminders:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        _buildReminderText(assignment.reminder),
                      ],
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

  Widget _buildReminderText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(fontSize: 16, color: Colors.blue)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// WIDGET: PeriodProgressIndicator (for the sliding dot/line)
// ----------------------------------------------------------------------
class PeriodProgressIndicator extends StatelessWidget {
  final Assignment assignment;
  final Assignment nextAssignment;

  const PeriodProgressIndicator({
    super.key,
    required this.assignment,
    required this.nextAssignment,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrent = assignment.isCurrentPeriod;

    Color lineColor = Colors.indigo;
    if (isCurrent) {
      lineColor = Colors.green;
    } else if (now.isAfter(assignment.endTime) && now.isBefore(nextAssignment.startTime)) {
      lineColor = Colors.grey.shade400;
    }

    double elapsedPercentage = 0.0;
    if (isCurrent) {
      final totalDuration = assignment.endTime.difference(assignment.startTime);
      final elapsedDuration = now.difference(assignment.startTime);

      if (totalDuration.inMilliseconds > 0) {
        elapsedPercentage = elapsedDuration.inMilliseconds / totalDuration.inMilliseconds;
        elapsedPercentage = elapsedPercentage.clamp(0.0, 1.0);
      }
    }

    return Container(
      width: 2,
      color: Colors.grey.shade400,
      child: isCurrent
          ? LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight = constraints.maxHeight;
                final animatedHeight = totalHeight * elapsedPercentage;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: Colors.indigo.shade100),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: animatedHeight,
                        width: 2,
                        color: Colors.green,
                      ),
                    ),
                    Positioned(
                      top: animatedHeight.clamp(0, totalHeight - 12),
                      left: -5,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : Container(color: lineColor),
    );
  }
}

// -----------------------------------------------------------------------------
// HOME SCREEN
// -----------------------------------------------------------------------------
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
  final ScheduleService _scheduleService = ScheduleService();

  static const int _homeViewIndex = 0;
  static const int _profileViewIndex = 1;

  int _selectedIndex = _homeViewIndex;
  List<Assignment> _submittedSchedule = [];
  String _totalHours = '0 hours 0 minutes';
  List<String> _daysToDisplay = [];

  List<PeriodNotification> _notifications = [];
  Timer? _scheduleTimer;
  Set<String> _notifiedPeriods = {};

  String _location = 'Perundurai, Erode';
  int _temperature = 32;

  String get _fullName {
    final middle = widget.middleName != null && widget.middleName!.isNotEmpty
        ? '${widget.middleName} '
        : '';
    return '${widget.firstName} $middle${widget.lastName}';
  }

  String get _facultyId => widget.email;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _loadAndFilterSchedule();
    _initializeWidgetOptions();
    _startScheduleTimer();
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  void _startScheduleTimer() {
    _scheduleTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (_submittedSchedule.isNotEmpty) {
          _checkTimetableForNotifications();
        }
        if (mounted) setState(() {});
      },
    );
  }

  void _checkTimetableForNotifications() {
    final now = DateTime.now();
    final day = DateFormat('EEE').format(now);
    final todayList = _submittedSchedule.where((a) => a.day == day).toList();

    for (var p in todayList) {
      final nKey = '${p.day}_${p.time}';
      final alertTime = p.startTime.subtract(const Duration(minutes: 5));

      if (now.isAfter(alertTime) &&
          now.isBefore(p.startTime) &&
          !_notifiedPeriods.contains(nKey)) {
        final note = PeriodNotification(
          title: 'Class Reminder: ${p.subject}',
          body:
              'Your class for ${p.subject} (${p.section}) starts in 5 minutes at ${TimeOfDay.fromDateTime(p.startTime).format(context)}.',
          time: now,
          isRead: false,
        );

        if (!mounted) return;
        setState(() {
          _notifications.insert(0, note);
          _notifiedPeriods.add(nKey);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(note.title),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (now.isAfter(p.endTime.add(const Duration(hours: 1)))) {
        _notifiedPeriods.remove(nKey);
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _updateNotifications(List<PeriodNotification>? list) {
    if (!mounted) return;
    setState(() => _notifications = list ?? []);
  }

  void _filterAssignmentsByDay(List<Assignment> schedule) {
    final now = DateTime.now();
    final current = now.weekday;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    _daysToDisplay = days.where((day) {
      if (!schedule.any((a) => a.day == day)) return false;
      if (day == 'Sun') return false;

      final idx = days.indexOf(day) + 1;
      if (idx > current) return true;
      if (idx == current) {
        return schedule.any((a) => a.day == day && now.isBefore(a.endTime));
      }
      return false;
    }).toList();
  }

  void _loadAndFilterSchedule() async {
    final data = await _scheduleService.loadSchedule(_facultyId);

    if (!mounted) return;
    setState(() {
      _submittedSchedule = data;
      _calculateTotalHours(data);
      _filterAssignmentsByDay(data);
      _initializeWidgetOptions();
    });
  }

  void _initializeWidgetOptions() {
    _widgetOptions = [
      VerticalTimeline(
        assignments: _submittedSchedule,
        totalHours: _totalHours,
        daysToDisplay: _daysToDisplay,
      ),
      ProfileScreen(
        firstName: widget.firstName,
        middleName: widget.middleName,
        lastName: widget.lastName,
        email: widget.email,
        phoneNo: widget.phoneNo,
        assignments: widget.assignments,
      ),
    ];
  }

  void _calculateTotalHours(List<Assignment> schedule) {
    const int periodMinutes = 50;
    final total = schedule.length * periodMinutes;
    final h = total ~/ 60;
    final m = total % 60;
    _totalHours = '$h hours $m minutes';
  }

  void _navigateToTimetable() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimeTableScreen(facultyName: _fullName),
      ),
    );

    if (result != null && result is List<Map<String, String>>) {
      final newSchedule = parseAssignedList(result);
      await _scheduleService.saveSchedule(_facultyId, newSchedule);

      if (!mounted) return;
      setState(() {
        _submittedSchedule = newSchedule;
        _calculateTotalHours(newSchedule);
        _filterAssignmentsByDay(newSchedule);
        _initializeWidgetOptions();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Timetable for ${_submittedSchedule.length} periods saved successfully!'),
        ),
      );
    }
  }

  void _navigateToChat() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(facultyName: _fullName)),
      );

  void _navigateToNotification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotifyScreen(
          notifications: _notifications,
          onNotificationsUpdated: _updateNotifications,
        ),
      ),
    );
  }

  void _onItemTapped(int bottomBarItemIndex) {
    setState(() {
      if (bottomBarItemIndex == 0) {
        _selectedIndex = _profileViewIndex;
      } else if (bottomBarItemIndex == 1) {
        _selectedIndex = _homeViewIndex;
      }
    });
  }

  Widget _buildNavItem(int bottomBarItemIndex, IconData icon, String label) {
    final int targetViewIndex =
        bottomBarItemIndex == 0 ? _profileViewIndex : _homeViewIndex;
    final bool isSelected = _selectedIndex == targetViewIndex;

    return Expanded(
      child: SizedBox(
        height: kBottomNavigationBarHeight,
        child: InkWell(
          onTap: () => _onItemTapped(bottomBarItemIndex),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade600,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _navigateToNotification,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWeatherAndHydrationCard(BuildContext context) {
    final bool isHot = _temperature >= 30;
    final String hydrationMessage = isHot
        ? 'Stay hydrated!'
        : 'Enjoy the weather!';
    final IconData weatherIcon = isHot ? Icons.wb_sunny : Icons.cloud;
    final Color tempColor = isHot ? Colors.red.shade700 : Colors.blue.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(weatherIcon, color: tempColor, size: 30),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_temperature°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: tempColor,
                        ),
                      ),
                      Text(
                        _location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  hydrationMessage,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHomeSelected = _selectedIndex == _homeViewIndex;

    return Scaffold(
      appBar: AppBar(
        leading: isHomeSelected
            ? IconButton(
                icon: const Icon(Icons.search),
                onPressed: _navigateToChat,
              )
            : null,
        title: Text('$_fullName - Faculty Portal'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: isHomeSelected
            ? [_buildNotificationIcon()]
            : [],
      ),
      body: isHomeSelected
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWeatherAndHydrationCard(context),
                  Center(
                    child: _widgetOptions.elementAt(_selectedIndex),
                  ),
                ],
              ),
            )
          : Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              _buildNavItem(0, Icons.person, 'Profile'),
              const Spacer(),
              _buildNavItem(1, Icons.home, 'Home'),
              const Spacer(),
              SizedBox(
                width: 60,
                height: kBottomNavigationBarHeight,
                child: IconButton(
                  icon: const Icon(Icons.calendar_month, size: 28),
                  color: Colors.indigo,
                  onPressed: _navigateToTimetable,
                  tooltip: 'Go to Timetable',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}