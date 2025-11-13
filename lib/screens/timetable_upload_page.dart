// lib/screens/timetable_upload_page.dart
import 'package:flutter/material.dart';

class TimetableUploadPage extends StatelessWidget {
  const TimetableUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Upload'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Registration Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please proceed to upload your faculty timetable for the current semester.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement actual file picker logic for timetable upload
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Timetable file picker logic goes here!')),
                  );
                },
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text('Upload Timetable', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}