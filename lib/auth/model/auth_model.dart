/// A data model for user authentication.
///
/// This class encapsulates the email and password credentials
/// required for a user to sign in.
class AuthModel {
  final String email;
  final String password;

  AuthModel({required this.email, required this.password});
}
