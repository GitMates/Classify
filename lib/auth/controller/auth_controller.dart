import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/auth_model.dart';

/// The controller for authentication logic.
///
/// This class manages the state and business logic for signing a user in
/// or creating a new account. It interacts with Firebase Auth and notifies
/// listeners of any changes.
class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  /// A getter to check the current loading state.
  bool get isLoading => _isLoading;

  /// Sets the loading state and notifies listeners.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Attempts to sign in a user with the provided credentials.
  ///
  /// Returns a [UserCredential] on success.
  /// Throws a [FirebaseAuthException] if Firebase returns an error.
  Future<UserCredential> signIn(AuthModel authModel) async {
    _setLoading(true);
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: authModel.email,
        password: authModel.password,
      );
      _setLoading(false);
      return userCredential;
    } on FirebaseAuthException {
      _setLoading(false);
      rethrow;
    }
  }

  /// Creates a new user account with the provided credentials.
  ///
  /// Returns a [UserCredential] on success.
  /// Throws a [FirebaseAuthException] if Firebase returns an error.
  Future<UserCredential> signUp(AuthModel authModel) async {
    _setLoading(true);
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: authModel.email,
        password: authModel.password,
      );
      _setLoading(false);
      return userCredential;
    } on FirebaseAuthException {
      _setLoading(false);
      rethrow;
    }
  }

  /// Returns a user-friendly error message based on the Firebase error code.
  String getErrorMessage(String errorCode) {
    return switch (errorCode) {
      'user-not-found' => 'No user found for that email.',
      'wrong-password' => 'Wrong password provided for that user.',
      'invalid-email' => 'The email address is not valid.',
      'weak-password' => 'The password is too weak.',
      'email-already-in-use' => 'An account already exists for that email.',
      'network-request-failed' =>
        'A network error occurred. Please check your connection.',
      _ => 'An unexpected error occurred. Please try again.',
    };
  }
}

