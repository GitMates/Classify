// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Import the Login screen

// You need to generate this file by running `flutterfire configure` 
// after setting up your project in the Firebase console.
import 'firebase_options.dart'; 

void main() async {
  // 1. Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase
  // This uses the configuration generated in firebase_options.dart
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const FacultyApp());
  } catch (e) {
    // In a real app, you would handle this error more gracefully (e.g., show an error screen)
    print("Error initializing Firebase: $e");
    runApp(const ErrorApp());
  }
}

class FacultyApp extends StatelessWidget {
  const FacultyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KEC Faculty Portal',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          color: Colors.indigo,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
      ),
      // Set the LoginScreen as the home page
      home: const LoginScreen(),
    );
  }
}

// Optional: A simple screen to display if Firebase initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize application. Check Firebase setup.', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}