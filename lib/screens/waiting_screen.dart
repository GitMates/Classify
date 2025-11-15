// lib/screens/waiting_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; 

// IMPORTANT: Change to StatefulWidget to manage the real-time stream
class WaitingScreen extends StatefulWidget {
  final String facultyName;
  final String facultyUid; // We need the UID to listen to the specific document

  const WaitingScreen({
    super.key,
    required this.facultyName,
    required this.facultyUid, // New required parameter
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
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

  // Helper function to navigate back to login
  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Status'),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false, // Prevents the back button
      ),
      // Use a StreamBuilder to listen for the faculty document status
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faculty')
            .doc(widget.facultyUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            // Handle case where document might be deleted or an error occurs
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error loading status. Please try again later.'),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => _goToLogin(context),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Extract the current status
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final status = data?['status'] ?? 'Pending'; // Default to Pending if missing

          // --- UI Logic based on Status ---
          Widget statusWidget;
          Color cardColor;
          IconData statusIcon;
          Color iconColor;
          String titleText;
          String bodyText;
          String buttonText;
          Color buttonColor;
          bool showLoginButton;

          if (status == 'Approved') {
            statusIcon = Icons.check_circle_outline;
            iconColor = Colors.green;
            cardColor = Colors.green.shade50;
            titleText = 'Registration Approved!';
            bodyText = 'Great news! The administrator has approved your registration. You can now log in to the system.';
            buttonText = 'Proceed to Login';
            buttonColor = Colors.green;
            showLoginButton = true;
          } else if (status == 'Rejected') {
            statusIcon = Icons.cancel_outlined;
            iconColor = Colors.red;
            cardColor = Colors.red.shade50;
            titleText = 'Registration Rejected';
            bodyText = 'Your registration was rejected by the administrator. Please contact the administration for details.';
            buttonText = 'Go to Login';
            buttonColor = Colors.red;
            showLoginButton = true;
          } else { // status == 'Pending' or any other state
            statusIcon = Icons.pending_actions;
            iconColor = Colors.orange;
            cardColor = Colors.blue.shade50;
            titleText = 'Awaiting Approval';
            bodyText = 'Your registration has been completed successfully. Please wait for the **Admin Approval** before attempting to log in.';
            buttonText = 'Go to Login';
            buttonColor = Colors.indigo;
            showLoginButton = false;
          }

          // Build the common layout
          statusWidget = Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // --- Icon ---
                Icon(
                  statusIcon,
                  color: iconColor,
                  size: 80,
                ),
                const SizedBox(height: 30),

                // --- Personalized Greeting ---
                Text(
                  '$greeting, ${widget.facultyName}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Approval Message Card ---
                Card(
                  elevation: 4,
                  color: cardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          titleText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: iconColor
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          bodyText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // --- Back to Login Button ---
                if (status != 'Pending') // Show button only when status is final (Approved/Rejected)
                  OutlinedButton(
                    onPressed: () => _goToLogin(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      side: BorderSide(color: buttonColor),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(fontSize: 18, color: buttonColor),
                    ),
                  ),
              ],
            ),
          );

          return Center(child: statusWidget);
        },
      ),
    );
  }
}