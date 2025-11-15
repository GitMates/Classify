// lib/screens/waiting_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart'; // To allow the user to go back to the login page

class WaitingScreen extends StatelessWidget {
final String facultyName;

const WaitingScreen({super.key, required this.facultyName});



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

 return Scaffold(
 appBar: AppBar(
 title: const Text('Registration Submitted'),
 backgroundColor: Colors.indigo,
 automaticallyImplyLeading: false, // Prevents the back button
 ),
 body: Center(
 child: Padding(
 padding: const EdgeInsets.all(30.0),
child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 crossAxisAlignment: CrossAxisAlignment.center,
 children: <Widget>[
// --- Icon ---
 const Icon(
Icons.pending_actions,
 color: Colors.orange,
 size: 80,
 ),
 const SizedBox(height: 30),

// --- Personalized Greeting ---
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

 // --- Approval Message ---
Card(
 elevation: 4,
 color: Colors.blue.shade50,
 margin: const EdgeInsets.symmetric(horizontal: 10),
 child: Padding(
 padding: const EdgeInsets.all(20.0),
 child: Column(
 children: [
 const Text(
 'Your registration has been completed successfully.',
 textAlign: TextAlign.center,
style: TextStyle(fontSize: 18, color: Colors.black87),
),
 const SizedBox(height: 10),
 Text(
'Please wait for the **Admin Approval** before attempting to log in.',
 textAlign: TextAlign.center,
 style: TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 color: Colors.red.shade700,
 ),
 ),
 ],
 ),
 ),
 ),
 const SizedBox(height: 40),
 // --- Back to Login Button ---
 OutlinedButton(
 onPressed: () {
 // Navigate back to the login screen and clear all previous routes
 Navigator.of(context).pushAndRemoveUntil(
 MaterialPageRoute(builder: (context) => const LoginScreen()),
 (Route<dynamic> route) => false,
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