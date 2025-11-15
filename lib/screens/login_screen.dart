// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pooja/screens/admin_dashboad.dart';
import 'register_screen.dart'; 
import 'package:pooja/screens/admin_dashboad.dart'; // File name: admin_dashboad.dart// Correctly imported from lib/screens/admin_dashboard.dart
// import 'faculty_dashboard.dart'; // <<< Uncomment this once you create the Faculty dashboard page

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
  
  UserRole _selectedRole = UserRole.faculty; // Default selection is Faculty
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
          // Admin login successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin Login Successful!')),
          );
          // Navigate to Admin Dashboard
Navigator.of(context).pushReplacement(
 MaterialPageRoute(builder: (context) => const AdminDashboard()), // <--- CORRECTED
);
        } else {
          // Admin login failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin Login Failed: Invalid Credentials.')),
          );
        }
      } else {
        // --- FACULTY LOGIN LOGIC (Firebase) ---
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Faculty login successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty Login Successful!')),
        );
        
        // Navigate to Faculty Dashboard (using a placeholder screen)
        // NOTE: Replace the placeholder below with your actual FacultyDashboard() once created:
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => const FacultyDashboard()),
        // );
         _navigateToPlaceholderDashboard('Faculty Dashboard');
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

  // Placeholder function for Faculty Dashboard until the file is ready
  void _navigateToPlaceholderDashboard(String role) {
     Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(role)),
          body: Center(child: Text('Welcome to the $role! (Create faculty_dashboard.dart)')),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Widget Build ---
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
              // --- ICON/LOGO (Centered) ---
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Image.asset(
                    'assets/login_logo.gif', 
                    height: 100, 
                  ),
                ),
              ),
              
              // --- Role Selection Radio Buttons ---
              const Text('Select Role:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  
                  // Specific Admin Email validation (only for Admin role selection)
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
              
              // --- Faculty Registration Link (Centered) ---
              if (_selectedRole == UserRole.faculty)
                Center( // This centers the TextButton itself
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('New Faculty? Register Here', style: TextStyle(color: Colors.indigo)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}