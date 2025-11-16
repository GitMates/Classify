// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Removed: import 'package:file_picker/file_picker.dart';
// Removed: import 'package:firebase_storage/firebase_storage.dart';
import 'waiting_screen.dart'; // Assuming this file exists for success navigation

// --- Model for Teaching Assignment ---
class TeachingAssignment {
  String? selectedClass;
  String? selectedDivision;
  String? selectedSubject;

  // Constructor
  TeachingAssignment({this.selectedClass, this.selectedDivision, this.selectedSubject});

  // A method to check if the assignment is complete (all fields selected)
  bool get isValid => selectedClass != null && selectedDivision != null && selectedSubject != null;

  // Method to convert to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'class': selectedClass,
      'division': selectedDivision,
      'subject': selectedSubject,
    };
  }
}
// ----------------------------------------

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); 

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  // Removed: final _storage = FirebaseStorage.instance;
  
  // Controllers for all fields
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Dropdown State 
  List<TeachingAssignment> _assignments = [TeachingAssignment()]; // Start with one assignment

  // Removed File Upload State
  // Removed: PlatformFile? _signatureFile;
  // Removed: PlatformFile? _photoFile;
  bool _isLoading = false;

  // Conditional data for dropdowns
  final List<String> _classOptions = ['I MCA', 'II MCA'];
  final Map<String, List<String>> _divisionOptions = {
    'I MCA': ['I-A', 'I-B'],
    'II MCA': ['II-A', 'II-B'],
  };
  final Map<String, List<String>> _subjectOptions = {
    'I MCA': ['C', 'SE', 'DSA', 'DBT', 'AM'],
    'II MCA': ['Linux', 'FSD', 'ML', 'AI', 'Python'],
  };

  // --- Utility Functions ---

  void _addAssignment() {
    setState(() {
      _assignments.add(TeachingAssignment());
    });
  }

  void _removeAssignment(int index) {
    setState(() {
      _assignments.removeAt(index);
    });
  }

  // Removed: _pickFile function
  // Removed: _uploadFile function
  
  // --- Main Submission Logic (Updated) ---

  Future<void> _registerFaculty() async {
    if (_formKey.currentState!.validate()) {
      
      // Validation for assignments list
      if (_assignments.isEmpty || !_assignments.every((a) => a.isValid)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all class, division, and subject selections, or remove incomplete entries.')),
        );
        return;
      }
      
      // Removed: File upload validation
      
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Create User in Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        String uid = userCredential.user!.uid;
        String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

        // Removed: File upload to Firebase Storage (signatureUrl, photoUrl variables removed)
        
        // Prepare assignments for Firestore
        final assignmentsList = _assignments.map((a) => a.toMap()).toList();
        
        // 2. Save User Data to Firestore (Updated to use empty strings for URLs)
        await _firestore.collection('faculty').doc(uid).set({
          'uid': uid,
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNo': _phoneController.text.trim(),
          'teachingAssignments': assignmentsList, 
          'signatureUrl': '', // Using empty string as placeholder
          'photoUrl': '',      // Using empty string as placeholder
          'registrationDate': FieldValue.serverTimestamp(),
          'status': 'Pending', 
        });

        // Success: Navigate to the Waiting Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful! Redirecting for approval.')),
        );

        // NEW code in register_screen.dart
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            // Pass the generated UID to the WaitingScreen
            builder: (context) => WaitingScreen(
              facultyName: fullName,
              facultyUid: uid, // <-- Pass the UID here
            ),
          ),
        );

      } on FirebaseAuthException catch (e) {
        String message = 'Registration failed. ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        // Catch all other errors 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Widget for Single Assignment Block (Reusable) ---
  Widget _buildAssignmentDropdowns(int index, TeachingAssignment assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assignment ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              // Remove button (only if more than one assignment exists)
              if (_assignments.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _removeAssignment(index),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Class and Division in a Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Class', border: OutlineInputBorder()),
                  value: assignment.selectedClass,
                  items: _classOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      assignment.selectedClass = newValue;
                      assignment.selectedDivision = null; // Reset division when class changes
                      assignment.selectedSubject = null; // Reset subject when class changes
                    });
                  },
                  validator: (value) => value == null ? 'Select a class' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Division', border: OutlineInputBorder()),
                  value: assignment.selectedDivision,
                  items: assignment.selectedClass != null && _divisionOptions.containsKey(assignment.selectedClass!)
                      ? _divisionOptions[assignment.selectedClass!]!
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList()
                      : [],
                  onChanged: (String? newValue) {
                    setState(() {
                      assignment.selectedDivision = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Select a division' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Subject Dropdown (Conditional - Full Width)
          if (assignment.selectedClass != null)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Subject', border: OutlineInputBorder()),
              value: assignment.selectedSubject,
              items: assignment.selectedClass != null && _subjectOptions.containsKey(assignment.selectedClass!)
                  ? _subjectOptions[assignment.selectedClass!]!
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList()
                  : [],
              onChanged: (String? newValue) {
                setState(() {
                  assignment.selectedSubject = newValue;
                });
              },
              validator: (value) => value == null ? 'Select a subject' : null,
            ),
        ],
      ),
    );
  }

  // --- Widget Build (Updated) ---

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Registration'),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: true, // Show back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- 1. Personal Details ---
              const Text('Personal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person)),
                      validator: (value) => value == null || value.isEmpty ? 'Enter first name' : null,
                    ),
                  ),
                  const SizedBox(width: 15), 
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person)),
                      validator: (value) => value == null || value.isEmpty ? 'Enter last name' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(labelText: 'Middle Name (Optional)', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 20), 

              // --- 2. Contact & Auth Details ---
              const Text('Contact & Authentication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'College Email ID (@kongu.edu)', prefixIcon: Icon(Icons.email)),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email address';
                  if (!value.endsWith('@kongu.edu')) return 'Email must end with @kongu.edu';
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Set Password (Min 6 chars)', prefixIcon: Icon(Icons.lock)),
                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 10),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone No (10 digits)', prefixIcon: Icon(Icons.phone)),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter phone number';
                  if (value.length != 10 || int.tryParse(value) == null) return 'Phone number must be exactly 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // --- 3. Teaching Assignments (Class, Division, Subject) ---
              const Text('Teaching Assignments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),

              // Dynamically build the list of assignment dropdowns
              ..._assignments.asMap().entries.map((entry) {
                int idx = entry.key;
                TeachingAssignment assignment = entry.value;
                return _buildAssignmentDropdowns(idx, assignment);
              }).toList(),
              
              // ADD Assignment Button
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Another Assignment'),
                onPressed: _addAssignment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  foregroundColor: Colors.indigo,
                  side: BorderSide(color: Colors.indigo.shade300),
                ),
              ),
              const SizedBox(height: 30), // Increased spacing after last section

              // Removed: --- 4. File Uploads (Signature and Photo) ---
              
              // --- Submit Button ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerFaculty,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'SUBMIT REGISTRATION',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}