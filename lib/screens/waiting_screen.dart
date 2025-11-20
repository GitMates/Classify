// lib/screens/waiting_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart'; // To allow the user to go back to the login page

class WaitingScreen extends StatelessWidget {
  final String facultyName;

  // Keeping the original constructor signature as requested (even though facultyUid is unused)
  const WaitingScreen({
    super.key,
    required this.facultyName,
    required String facultyUid,
  });

  // Function to determine the time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();

    // Use a variable for the asset path to prevent repetition
    const String assetPath = 'assets/waiting_logo.jpg'; // Your specified path

    final imageWidget = Image.asset(
      assetPath,
      height: 120,
      // Ensure the image loads; use a placeholder or error builder if needed
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon if the GIF fails to load (e.g., missing asset registration)
        return const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 80,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Submitted'),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false, // Prevents back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // GIF Image (Replaced the 'image' variable with imageWidget)
              imageWidget, 
              const SizedBox(height: 30),

              // *** REMOVED THE FOLLOWING ICON WIDGET: ***
              // const Icon(
              //   Icons.pending_actions,
              //   color: Colors.orange,
              //   size: 80,
              // ),
              // const SizedBox(height: 30), // Adjusted spacing if needed

              // Personalized Greeting
              Text(
                '$greeting, $facultyName!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              const SizedBox(height: 20),

              // Approval Message Card
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Your registration has been completed successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please wait for the **Admin Approval** before attempting to log in.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 182, 50, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Back to Login Button
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  side: const BorderSide(color: Colors.indigo),
                ),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(fontSize: 18, color: Colors.indigo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}