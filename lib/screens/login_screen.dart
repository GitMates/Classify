// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pooja/screens/admin_dashboad.dart';
import 'register_screen.dart';
import 'package:pooja/screens/profile_screen.dart';
import 'package:pooja/screens/timetable_screen.dart' hide HomeScreen;
import 'package:pooja/screens/home_screen.dart'; // CHANGE 1: ADD HOME SCREEN IMPORT
import 'waiting_screen.dart'; // For Pending status
import 'notes_screen.dart';

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

  // --- Login Logic ---
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_selectedRole == UserRole.admin) {
        // --- ADMIN LOGIN LOGIC ---
        if (_adminCredentials.containsKey(email) && _adminCredentials[email] == password) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin Login Successful!')),
          );

          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin Login Failed: Invalid Credentials.')),
          );
        }
      } else {
        // --- FACULTY LOGIN LOGIC (Firebase + Status Check) ---

        // 1. Authenticate user
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCredential.user!.uid;

        // 2. Fetch user status and data from Firestore
        DocumentSnapshot facultyDoc = await FirebaseFirestore.instance.collection('faculty').doc(uid).get();

        if (!facultyDoc.exists) {
          await FirebaseAuth.instance.signOut();
          throw Exception('Faculty data not found. Please contact admin.');
        }

        final data = facultyDoc.data() as Map<String, dynamic>;
        final status = data['status'];

        // Extract name fields safely
        final facultyFirstName = data['firstName'] as String? ?? '';
        final facultyMiddleName = data['middleName'] as String? ?? '';
        final facultyLastName = data['lastName'] as String? ?? '';
        final facultyEmail = data['email'] as String? ?? '';
        final facultyPhone = data['phoneNo'] as String? ?? '';

        // Process teaching assignments
        final List<dynamic> teachingAssignmentsMap = data['teachingAssignments'] as List<dynamic>? ?? [];
        final List<String> assignments = teachingAssignmentsMap.map((assignmentMap) {
          final aClass = assignmentMap['class'] ?? 'N/A';
          final aDivision = assignmentMap['division'] ?? 'N/A';
          final aSubject = assignmentMap['subject'] ?? 'N/A';
          return '$aClass - $aDivision - $aSubject';
        }).toList();

        // 3. Navigate based on status
        if (status == 'Approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Faculty Login Successful!')),
          );

          if (context.mounted) {
            // CHANGE 2: NAVIGATE TO HOME SCREEN
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  firstName: facultyFirstName,
                  middleName: facultyMiddleName,
                  lastName: facultyLastName,
                  email: facultyEmail,
                  phoneNo: facultyPhone,
                  assignments: assignments,
                ),
              ),
            );
          }
        } else if (status == 'Pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Approval is still pending. Please wait.')),
          );

          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => WaitingScreen(
                  facultyName: '$facultyFirstName $facultyLastName',
                  facultyUid: uid,
                ),
              ),
            );
          }
        } else if (status == 'Rejected') {
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account rejected by admin. Contact support.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Check your email and password.';
      if (e.code == 'user-not-found') {
        message = 'No faculty found with that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KEC Portal Login'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Logo ---
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Image.asset(
                    'assets/login_logo.gif',
                    height: 100,
                  ),
                ),
              ),

              // --- Role Selection ---
              const Text(
                'Select Role:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: RadioListTile<UserRole>(
                      title: const Text('Faculty'),
                      value: UserRole.faculty,
                      groupValue: _selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<UserRole>(
                      title: const Text('Admin'),
                      value: UserRole.admin,
                      groupValue: _selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Email Field ---
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Kongu Email ID',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!value.endsWith('@kongu.edu')) {
                    return 'Email must end with @kongu.edu';
                  }
                  if (_selectedRole == UserRole.admin && !_adminCredentials.containsKey(value.trim())) {
                    return 'This email is not authorized for Admin login.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Password Field ---
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // --- Login Button ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRole == UserRole.admin ? Colors.red.shade700 : Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        _selectedRole == UserRole.admin ? 'ADMIN LOGIN' : 'FACULTY LOGIN',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 20),

              // --- Registration Link (Faculty only) ---
              if (_selectedRole == UserRole.faculty)
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'New Faculty? Register Here',
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}