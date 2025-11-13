import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart'; // Faculty Welcome Page (Assumed)
import 'package:pooja/admin_dashboard.dart'; // Admin Dashboard Page (Assumed)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLogin = true; // Toggle between Login and Registration (Faculty only)
  bool _isAdminMode = false; // Toggle between Faculty and Admin mode
  bool _isLoading = false;
  String _errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Admin Logic Constants ---
  static const Map<String, String> _adminCredentials = {
    'vaishnavi@kongu.edu': '123456',
    'pavi@kongu.edu': '987654',
  };

  // --- Utility Functions ---

  void _navigateToWelcomePage(String name) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WelcomePage(facultyName: name),
      ),
    );
  }

  void _navigateToAdminDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AdminDashboard(),
      ),
    );
  }

  // --- Firebase/Admin Authentication Functions ---

  // Handles User Registration (Faculty only)
  Future<void> _handleRegistration() async {
    // Basic validation for email domain
    if (!_emailController.text.endsWith('@kongu.edu')) {
      setState(() {
        _errorMessage = 'Registration is only allowed for emails ending with @kongu.edu.';
      });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String facultyName = _nameController.text.trim();

      await _firestore.collection('faculty_users').doc(userCredential.user!.uid).set({
        'name': facultyName,
        'email': _emailController.text.trim(),
        'role': 'faculty',
        'status': 'accepted', 
        'registeredAt': FieldValue.serverTimestamp(),
      });

      _navigateToWelcomePage(facultyName);

    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = e.message ?? 'Registration failed.'; });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // Handles Admin Login (Local Check)
  Future<void> _handleAdminLogin() async {
    setState(() { _isLoading = true; _errorMessage = ''; });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (_adminCredentials.containsKey(email) && _adminCredentials[email] == password) {
      _navigateToAdminDashboard();
    } else {
      setState(() {
        _errorMessage = 'Invalid Admin email or password.';
      });
    }

    setState(() { _isLoading = false; });
  }

  // Handles Faculty Login (Firebase Check)
  Future<void> _handleFacultyLogin() async {
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      // 1. Perform Firebase Auth Sign-In
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final String userId = userCredential.user!.uid;

      // 2. Fetch User Document from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('faculty_users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        await _auth.signOut();
        setState(() {
          _errorMessage = 'Account record not found. Please re-register or contact admin.';
        });
        return;
      }
      
      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      final userStatus = userData['status'];
      final facultyName = userData['name'] ?? 'Faculty Member'; 

      if (userStatus != 'accepted') {
        await _auth.signOut(); // Sign out unauthorized user
        setState(() {
          _errorMessage = userStatus == 'pending' 
              ? 'Your account is pending admin approval.' 
              : 'Your account is inactive or has been declined.';
        });
        return;
      }

      // 3. SUCCESS: Navigate to the welcome page
      _navigateToWelcomePage(facultyName);
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Generic error message for security
        _errorMessage = 'Login failed. Invalid email or password.'; 
      });
    } catch (e) {
      print('Login Error: $e'); 
      setState(() { _errorMessage = 'An unexpected error occurred. Please try again.'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // Main login/register handler
  void _submitAuthForm() {
    if (_formKey.currentState!.validate()) {
      if (_isAdminMode) {
        _handleAdminLogin();
      } else if (_isLogin) {
        _handleFacultyLogin();
      } else {
        _handleRegistration();
      }
    }
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final authModeText = _isAdminMode
        ? 'Admin Portal'
        : (_isLogin ? 'Faculty Login' : 'New Faculty Registration');

    // Determine colors based on mode for a cohesive look
    final primaryColor = _isAdminMode ? Colors.red.shade700 : Colors.indigo.shade700;
    final accentColor = _isAdminMode ? Colors.red.shade300 : Colors.indigo.shade300;

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light, professional background
      appBar: AppBar(
        title: Text(authModeText, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      
      // Floating Action Button for Submission
      floatingActionButton: _isLoading
          ? const CircularProgressIndicator()
          : FloatingActionButton.extended(
              onPressed: _submitAuthForm,
              icon: Icon(_isAdminMode ? Icons.admin_panel_settings : (_isLogin ? Icons.login : Icons.app_registration)),
              label: Text(
                _isAdminMode ? 'ADMIN LOGIN' : (_isLogin ? 'FACULTY LOGIN' : 'REGISTER ACCOUNT'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              extendedPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form( 
                key: _formKey,
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    
                    // --- CUSTOM IMAGE / ICONE (Placed at the very top) ---
                    Image.asset(
                      'assests/login_screen.png', 
                      height: 120, // Adjust size as needed
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback icon if the image asset is not configured correctly
                        return Icon(
                          Icons.business_center, 
                          size: 100, 
                          color: primaryColor.withOpacity(0.5)
                        );
                      }
                    ),
                    
                    // Increased spacing after image/icon, replacing the removed title text and its spacing
                    const SizedBox(height: 40), 

                    // Role Selector Toggle (Improved visual style)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ToggleButtons(
                        isSelected: [_isAdminMode == false, _isAdminMode == true],
                        onPressed: (int index) {
                          setState(() {
                            _isAdminMode = index == 1; 
                            _isLogin = true; 
                            _errorMessage = '';
                            _formKey.currentState?.reset();
                            _emailController.clear();
                            _passwordController.clear();
                            _nameController.clear();
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        selectedColor: Colors.white,
                        fillColor: primaryColor,
                        color: Colors.grey.shade700,
                        borderColor: Colors.transparent,
                        selectedBorderColor: Colors.transparent,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text('Faculty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text('Admin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Error Message Display
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Name Field (Only for Faculty Registration)
                    if (!_isAdminMode && !_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) { 
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: _isAdminMode ? 'Admin Email ID' : 'KEC Email ID (@kongu.edu)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        prefixIcon: const Icon(Icons.email_outlined),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email.';
                        }
                        // Admin and Faculty must use @kongu.edu for both login and registration
                        if (!value.endsWith('@kongu.edu')) {
                           return 'Email must end with @kongu.edu.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        if (!_isAdminMode && !_isLogin && value.length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Faculty Toggle Button (Hidden in Admin Mode)
                    if (!_isAdminMode)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = '';
                            _formKey.currentState?.reset();
                            _nameController.clear();
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Need an account? Register Here'
                              : 'Already have an account? Login',
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    
                    // Added extra space so the last element is not hidden by the FAB
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}