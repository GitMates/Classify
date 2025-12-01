// notify_screen.dart

import 'package:flutter/material.dart';

// 1. Define a dedicated typedef for the function signature
typedef NotificationsUpdateCallback = void Function(List<PeriodNotification> list);

// Data model for the notification item
class PeriodNotification {
  final String title;
  final String body;
  final DateTime time;
  // 🌟 EDITED: Making isRead final enforces immutability, 
  // aligning with the copyWith pattern.
  final bool isRead; 

  PeriodNotification({
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  // Method to create a copy with updated read status
  PeriodNotification copyWith({
    bool? isRead,
  }) {
    return PeriodNotification(
      title: title,
      body: body,
      time: time,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotifyScreen extends StatefulWidget {
  final List<PeriodNotification> notifications;
  // 2. Use the defined typedef for a cleaner type signature
  final NotificationsUpdateCallback onNotificationsUpdated; 

  const NotifyScreen({
    super.key,
    required this.notifications,
    required this.onNotificationsUpdated,
  });

  @override
  State<NotifyScreen> createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  // We use late to assign in initState
  late List<PeriodNotification> _notifications; 

  @override
  void initState() {
    super.initState();
    // Use deep copy of the list of immutable objects to avoid unexpected side effects
    _notifications = widget.notifications.map((n) => n.copyWith()).toList();
    _markAllAsRead();
  }

  // Good practice: call the parent function when the widget is disposed/closed
  @override
  void dispose() {
    // Ensure the final state of notifications is passed back before the screen closes
    widget.onNotificationsUpdated(_notifications);
    super.dispose();
  }

  void _markAllAsRead() {
    bool changed = false;
    final updatedList = _notifications.map((n) {
      if (!n.isRead) {
        changed = true;
        // The copyWith method ensures we don't mutate the original list item
        return n.copyWith(isRead: true); 
      }
      return n;
    }).toList();
    
    if (changed) {
      setState(() {
        _notifications = updatedList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Period Reminders'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _notifications.isEmpty
          ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('No recent class reminders.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    Text('Timetable reminders will appear here 5 minutes before class.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                
                // Get the time and format it using the current BuildContext
                final TimeOfDay notificationTime = TimeOfDay.fromDateTime(notification.time);
                final String formattedTime = notificationTime.format(context); 

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Icon(Icons.schedule, color: Colors.indigo.shade600),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    subtitle: Text(
                      notification.body,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}