// lib/screens/login_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pooja/screens/admin_dashboad.dart';
import 'register_screen.dart';
import 'package:pooja/screens/profile_screen.dart';
import 'package:pooja/screens/timetable_screen.dart';
import 'package:pooja/screens/home_screen.dart';
import 'waiting_screen.dart'; // For Pending status

enum UserRole { faculty, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.faculty; // Default: Faculty
  bool _isLoading = false;

  // Hardcoded Admin Credentials
  final Map<String, String> _adminCredentials = {
    'vaishnavi@kongu.edu': '123456',
    'pavi@kongu.edu': '987654',
  };

  // --- Login Logic (Unchanged) ---
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      if (_selectedRole == UserRole.admin) {
        // --- Admin Login ---
        if (_adminCredentials.containsKey(email) && _adminCredentials[email] == password) {
          // Admin login is successful (simulated)
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          // Show error for admin
          _showSnackBar('Invalid Admin Credentials.', Colors.red);
        }
      } else {
        // --- Faculty Login (Firebase Auth) ---
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          final docRef = FirebaseFirestore.instance.collection('faculties').doc(user.uid);
          final userDoc = await docRef.get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final String status = userData['status'] ?? 'Pending';
            final String firstName = userData['firstName'] ?? 'Faculty';
            final String lastName = userData['lastName'] ?? '';
            final String facultyName = '$firstName $lastName'.trim();

            if (status == 'Approved') {
              // --- Approved Faculty: Navigate to HomeScreen (Updated to pass name) ---
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    // PASS THE FACULTY NAME HERE
                    builder: (context) => HomeScreen(facultyName: facultyName),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            } else if (status == 'Pending') {
              // --- Pending Faculty: Navigate to WaitingScreen ---
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => WaitingScreen(
                      facultyName: facultyName,
                      facultyUid: user.uid,
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            } else if (status == 'Rejected') {
              // Rejected faculty should not be allowed to log in (or show a message)
              _showSnackBar('Your registration was rejected. Please contact the admin.', Colors.red);
              await FirebaseAuth.instance.signOut(); // Sign out the rejected user
            }
          } else {
            // User exists in Auth but not in Firestore (data issue)
            _showSnackBar('User data not found. Please re-register or contact admin.', Colors.red);
            await FirebaseAuth.instance.signOut();
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else {
        message = 'Login failed: ${e.message}';
      }
      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.', Colors.red);
      if (kDebugMode) {
        print(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Utility Functions ---

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Role Selector Widget (Unchanged) ---
  Widget _buildRoleSegment(UserRole role, String text) {
    final bool isSelected = _selectedRole == role;
    final Color selectedColor = Colors.indigo.shade700; // A slightly darker blue for selection

    BorderRadius segmentBorderRadius;
    if (role == UserRole.faculty) {
      segmentBorderRadius = const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomLeft: Radius.circular(8.0),
      );
    } else {
      segmentBorderRadius = const BorderRadius.only(
        topRight: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      );
    }
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: AnimatedContainer( // Use AnimatedContainer for smooth transitions
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: segmentBorderRadius, // Apply specific rounded corners
            border: Border.all(color: selectedColor), // Add border to the whole segment
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Build Method (Unchanged) ---
  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method is unchanged)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty/Admin Login'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // --- Title/Logo ---
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to access your portal.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // --- Role Selector ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.indigo.shade700),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRoleSegment(UserRole.faculty, 'Faculty'),
                      _buildRoleSegment(UserRole.admin, 'Admin'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- Email Field ---
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Password Field ---
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // --- Login Button ---
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 30),

                // --- Register Link ---
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register Here",
                    style: TextStyle(color: Colors.indigo.shade600, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}