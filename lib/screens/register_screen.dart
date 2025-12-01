// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waiting_screen.dart';

// --- Model for Teaching Assignment ---
class TeachingAssignment {
  String? selectedClass;
  String? selectedDivision;
  String? selectedSubject;

  TeachingAssignment({this.selectedClass, this.selectedDivision, this.selectedSubject});

  bool get isValid => selectedClass != null && selectedDivision != null && selectedSubject != null;

  Map<String, dynamic> toMap() {
    return {
      'class': selectedClass,
      'division': selectedDivision,
      'subject': selectedSubject,
    };
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); 

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  List<TeachingAssignment> _assignments = [TeachingAssignment()];
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _classOptions = ['I MCA', 'II MCA'];
  final Map<String, List<String>> _divisionOptions = {
    'I MCA': ['I-A', 'I-B'],
    'II MCA': ['II-A', 'II-B'],
  };
  final Map<String, List<String>> _subjectOptions = {
    'I MCA': ['C', 'SE', 'DSA', 'DBT', 'AM'],
    'II MCA': ['Linux', 'FSD', 'ML', 'AI', 'Python'],
  };

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

  Future<void> _registerFaculty() async {
    if (_formKey.currentState!.validate()) {
      
      if (_assignments.isEmpty || !_assignments.every((a) => a.isValid)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Please complete all assignments or remove incomplete entries.')),
              ],
            ),
            backgroundColor: Color(0xFFFF7043),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        String uid = userCredential.user!.uid;
        String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

        final assignmentsList = _assignments.map((a) => a.toMap()).toList();
        
        await _firestore.collection('faculty').doc(uid).set({
          'uid': uid,
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNo': _phoneController.text.trim(),
          'teachingAssignments': assignmentsList, 
          'signatureUrl': '',
          'photoUrl': '',
          'registrationDate': FieldValue.serverTimestamp(),
          'status': 'Pending', 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Registration Successful!'),
              ],
            ),
            backgroundColor: Color(0xFF66BB6A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WaitingScreen(
              facultyName: fullName,
              facultyUid: uid,
            ),
          ),
        );

      } on FirebaseAuthException catch (e) {
        String message = 'Registration failed. ${e.message}';
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
  }

  Widget _buildAssignmentDropdowns(int index, TeachingAssignment assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2a5298).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2a5298).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.assignment, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Assignment ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (_assignments.length > 1)
                  InkWell(
                    onTap: () => _removeAssignment(index),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Class',
                          prefixIcon: Icon(Icons.class_, color: Color(0xFF2a5298), size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF2a5298), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        value: assignment.selectedClass,
                        items: _classOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            assignment.selectedClass = newValue;
                            assignment.selectedDivision = null;
                            assignment.selectedSubject = null;
                          });
                        },
                        validator: (value) => value == null ? 'Select a class' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Division',
                          prefixIcon: Icon(Icons.group, color: Color(0xFF2a5298), size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF2a5298), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        value: assignment.selectedDivision,
                        items: assignment.selectedClass != null && _divisionOptions.containsKey(assignment.selectedClass!)
                            ? _divisionOptions[assignment.selectedClass!]!
                                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                                .toList()
                            : [],
                        onChanged: (String? newValue) {
                          setState(() {
                            assignment.selectedDivision = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Select division' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (assignment.selectedClass != null)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.book, color: Color(0xFF2a5298), size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF2a5298), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    value: assignment.selectedSubject,
                    items: assignment.selectedClass != null && _subjectOptions.containsKey(assignment.selectedClass!)
                        ? _subjectOptions[assignment.selectedClass!]!
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                            .toList()
                        : [],
                    onChanged: (String? newValue) {
                      setState(() {
                        assignment.selectedSubject = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Select subject' : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1e3c72),
              Color(0xFF2a5298),
              Color(0xFF7474BF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_add, color: Color(0xFF1e3c72), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Faculty Registration',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Create your account',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Personal Details Section
                          _buildSectionHeader('Personal Details', Icons.person_outline),
                          const SizedBox(height: 16),
                          
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  icon: Icons.person,
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12), 
                              Expanded(
                                child: _buildTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  icon: Icons.person,
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          _buildTextField(
                            controller: _middleNameController,
                            label: 'Middle Name (Optional)',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 24), 

                          // Contact & Authentication Section
                          _buildSectionHeader('Contact & Authentication', Icons.security),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _emailController,
                            label: 'College Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            hint: 'example@kongu.edu',
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (!value.endsWith('@kongu.edu')) return 'Must end with @kongu.edu';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            hint: 'Min 6 characters',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFF2a5298),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) => value == null || value.length < 6 ? 'Min 6 characters' : null,
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            hint: '10 digits',
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (value.length != 10 || int.tryParse(value) == null) return 'Must be 10 digits';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Teaching Assignments Section
                          _buildSectionHeader('Teaching Assignments', Icons.school),
                          const SizedBox(height: 16),

                          ..._assignments.asMap().entries.map((entry) {
                            int idx = entry.key;
                            TeachingAssignment assignment = entry.value;
                            return _buildAssignmentDropdowns(idx, assignment);
                          }).toList(),
                          
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1e3c72).withOpacity(0.1), Color(0xFF2a5298).withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF2a5298).withOpacity(0.3), width: 1.5),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _addAssignment,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline, color: Color(0xFF2a5298), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add Another Assignment',
                                        style: TextStyle(
                                          color: Color(0xFF2a5298),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Submit Button
                          _isLoading
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF66BB6A).withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _registerFaculty,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, size: 22),
                                        SizedBox(width: 10),
                                        Text(
                                          'SUBMIT REGISTRATION',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: Color(0xFF2a5298), width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2a5298), size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF2a5298), size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2a5298).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2a5298), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFEF5350)),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}