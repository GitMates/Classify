import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/auth_controller.dart';
import '../model/auth_model.dart';

/// The authentication screen UI.
///
/// This widget is responsible for rendering the login and sign-up forms
/// and handling user input. It uses an [AuthController] to perform the logic.
class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  final _formKey = GlobalKey<FormState>();

  // A boolean to toggle between Login and Sign Up modes.
  bool _isLoginMode = true;

  /// Toggles the form between login and signup modes.
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  /// Handles the authentication button press for both login and sign up.
  Future<void> _authenticate() async {
    // Validate the form fields before proceeding.
    if (!_formKey.currentState!.validate()) return;

    // Create a model with the user's input.
    final authModel = AuthModel(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    try {
      // Call the appropriate controller method based on the current mode.
      if (_isLoginMode) {
        await _authController.signIn(authModel);
      } else {
        await _authController.signUp(authModel);
      }

      // Show success message if the widget is still in the tree.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('${_isLoginMode ? 'Login' : 'Sign Up'} Successful!'),
        ),
      );
      // TODO: Navigate to the home screen on successful authentication.
    } on FirebaseAuthException catch (e) {
      // Get a user-friendly error message from the controller.
      final errorMessage = _authController.getErrorMessage(e.code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(errorMessage),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to changes in the controller to rebuild the widget when loading state changes.
    _authController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title changes depending on the mode.
        title: Text(_isLoginMode ? 'User Login' : 'Create Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Input Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Password Input Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // Main action button (Login or Sign Up)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: _authController.isLoading ? null : _authenticate,
                child: _authController.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(_isLoginMode ? 'Login' : 'Sign Up'),
              ),
              const SizedBox(height: 16.0),

              // Button to toggle between modes
              TextButton(
                onPressed: _toggleMode,
                child: Text(_isLoginMode
                    ? 'Don\'t have an account? Sign Up'
                    : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

