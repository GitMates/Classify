// lib/screens/welcome_page.dart
import 'package:flutter/material.dart';
// Assuming the new registration page file is named personal_registration_page.dart
import 'personal_registration_page.dart'; // Import the new page

class WelcomePage extends StatelessWidget {
  final String facultyName;

  const WelcomePage({super.key, required this.facultyName});

  // Function to handle navigation to the personal registration page
  void _navigateToPersonalRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // FIX APPLIED HERE: Changed to 'PersonalRegistrationPage()' (PascalCase)
        builder: (context) => const PersonalRegistrationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'), // Changed title for better context
        backgroundColor: Colors.indigo, // Changed color to match login screen
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.school, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text(
                'Welcome, Faculty!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                facultyName,
                style: const TextStyle(fontSize: 32, color: Colors.indigo, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                'You have successfully logged in with your KEC Faculty account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),

              // 🌟 NEW REGISTRATION BUTTON 🌟
              SizedBox(
                width: 250, // Fixed width for consistent button size
                child: ElevatedButton(
                  onPressed: () => _navigateToPersonalRegistration(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Register Personal Details',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Logout Button
              SizedBox(
                width: 250, // Fixed width for consistent button size
                child: ElevatedButton(
                  onPressed: () {
                    // Implement Sign Out/Logout logic here (e.g., FirebaseAuth.instance.signOut())
                    Navigator.of(context).pop(); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}