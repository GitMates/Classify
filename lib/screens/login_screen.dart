// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pooja/screens/admin_dashboad.dart';
import 'register_screen.dart';
import 'package:pooja/screens/profile_screen.dart';
import 'package:pooja/screens/timetable_screen.dart';
import 'package:pooja/screens/home_screen.dart';
import 'waiting_screen.dart';

enum UserRole { faculty, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.faculty;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, String> _adminCredentials = {
    'vaishnavi@kongu.edu': '123456',
    'pavi@kongu.edu': '987654',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

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
        if (_adminCredentials.containsKey(email) && _adminCredentials[email] == password) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Admin Login Successful!'),
                ],
              ),
              backgroundColor: Color(0xFF66BB6A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );

          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Admin Login Failed: Invalid Credentials.'),
                ],
              ),
              backgroundColor: Color(0xFFEF5350),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCredential.user!.uid;

        DocumentSnapshot facultyDoc = await FirebaseFirestore.instance.collection('faculty').doc(uid).get();

        if (!facultyDoc.exists) {
          await FirebaseAuth.instance.signOut();
          throw Exception('Faculty data not found. Please contact admin.');
        }

        final data = facultyDoc.data() as Map<String, dynamic>;
        final status = data['status'];

        final facultyFirstName = data['firstName'] as String? ?? '';
        final facultyMiddleName = data['middleName'] as String? ?? '';
        final facultyLastName = data['lastName'] as String? ?? '';
        final facultyEmail = data['email'] as String? ?? '';
        final facultyPhone = data['phoneNo'] as String? ?? '';

        final List<dynamic> teachingAssignmentsMap = data['teachingAssignments'] as List<dynamic>? ?? [];
        final List<String> assignments = teachingAssignmentsMap.map((assignmentMap) {
          final aClass = assignmentMap['class'] ?? 'N/A';
          final aDivision = assignmentMap['division'] ?? 'N/A';
          final aSubject = assignmentMap['subject'] ?? 'N/A';
          return '$aClass - $aDivision - $aSubject';
        }).toList();

        if (status == 'Approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Faculty Login Successful!'),
                ],
              ),
              backgroundColor: Color(0xFF66BB6A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );

          if (context.mounted) {
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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Approval is still pending. Please wait.'),
                ],
              ),
              backgroundColor: Color(0xFFFFA726),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.cancel, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Account rejected by admin. Contact support.'),
                ],
              ),
              backgroundColor: Color(0xFFEF5350),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
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
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('An unexpected error occurred: $e')),
            ],
          ),
          backgroundColor: Color(0xFFEF5350),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _selectedRole == UserRole.admin ? Color(0xFFEF5350) : Color(0xFF2a5298);
    final secondaryColor = _selectedRole == UserRole.admin ? Color(0xFFE53935) : Color(0xFF1e3c72);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _selectedRole == UserRole.admin
                ? [Color(0xFFFFEBEE), Color(0xFFFFCDD2), Color(0xFFFFFFFF)]
                : [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // --- Logo & Title Section ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/login_logo.gif',
                          height: 70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryColor, secondaryColor],
                        ).createShader(bounds),
                        child: const Text(
                          'KEC Portal',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back! Please login to continue',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Role Selection Card ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_outline, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Select Your Role',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = UserRole.faculty;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: _selectedRole == UserRole.faculty
                                              ? LinearGradient(
                                                  colors: [Color(0xFF2a5298).withOpacity(0.15), Color(0xFF1e3c72).withOpacity(0.1)],
                                                )
                                              : null,
                                          color: _selectedRole == UserRole.faculty ? null : Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: _selectedRole == UserRole.faculty
                                                ? Color(0xFF2a5298)
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.school_outlined,
                                              color: _selectedRole == UserRole.faculty
                                                  ? Color(0xFF2a5298)
                                                  : Colors.grey.shade400,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Faculty',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedRole == UserRole.faculty
                                                    ? Color(0xFF2a5298)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = UserRole.admin;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: _selectedRole == UserRole.admin
                                              ? LinearGradient(
                                                  colors: [Color(0xFFEF5350).withOpacity(0.15), Color(0xFFE53935).withOpacity(0.1)],
                                                )
                                              : null,
                                          color: _selectedRole == UserRole.admin ? null : Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: _selectedRole == UserRole.admin
                                                ? Color(0xFFEF5350)
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.admin_panel_settings_outlined,
                                              color: _selectedRole == UserRole.admin
                                                  ? Color(0xFFEF5350)
                                                  : Colors.grey.shade400,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Admin',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedRole == UserRole.admin
                                                    ? Color(0xFFEF5350)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Email Field ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Kongu Email ID',
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            prefixIcon: Icon(Icons.email_outlined, color: primaryColor, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      ),
                      const SizedBox(height: 16),

                      // --- Password Field ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            prefixIcon: Icon(Icons.lock_outlined, color: primaryColor, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      ),
                      const SizedBox(height: 28),

                      // --- Login Button ---
                      _isLoading
                          ? Container(
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor.withOpacity(0.7), secondaryColor.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _loginUser,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 54,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _selectedRole == UserRole.admin ? 'ADMIN LOGIN' : 'FACULTY LOGIN',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      // --- Registration Link ---
                      if (_selectedRole == UserRole.faculty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'New Faculty? ',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                Text(
                                  'Register Here',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.arrow_forward, color: primaryColor, size: 16),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}