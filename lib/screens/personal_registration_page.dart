// lib/screens/personal_registration_page.dart
import 'package:flutter/material.dart';
import 'timetable_upload_page.dart'; // Import the next page

class PersonalRegistrationPage extends StatefulWidget {
  const PersonalRegistrationPage({super.key});

  @override
  State<PersonalRegistrationPage> createState() => _PersonalRegistrationPageState();
}

class _PersonalRegistrationPageState extends State<PersonalRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Field Controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Dropdown State
  String? _selectedCourse;
  String? _selectedDivision;
  String? _selectedSubject;

  // Conditional Subject Data based on Course
  final Map<String, List<String>> _subjectsByCourse = {
    'I MCA': ['C', 'SE', 'DSA', 'DBT', 'AM'],
    'II MCA': ['Linux', 'FSD', 'ML', 'AI', 'Python'],
  };

  // Placeholder for uploaded file paths
  String? _signaturePath;
  String? _photoPath;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Validation Functions ---

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is mandatory';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is mandatory';
    }
    const pattern = r'^[\w-\.]+@kongu\.edu$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Email must end with @kongu.edu';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is mandatory';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  // --- Form Submission Handler ---

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // MANDATORY check for uploads
      if (_signaturePath == null || _photoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action Required: Please upload both signature and photo files to proceed.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // If form is valid and files are "uploaded," proceed to next page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal details saved! Proceeding to timetable setup.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Timetable Upload Page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TimetableUploadPage(),
        ),
      );
    }
  }

  // --- Widget Builders ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon, // Added Icon parameter
    String? Function(String?)? validator,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? ' (Optional)' : ' *'),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          prefixIcon: Icon(icon, color: Colors.blue.shade800), // Using the icon
        ),
        validator: validator ?? (value) => _validateRequired(value, labelText),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String labelText,
    required IconData icon, // Added Icon parameter
    required List<T> items,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: '$labelText *',
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          prefixIcon: Icon(icon, color: Colors.blue.shade800), // Using the icon
        ),
        value: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildFileUploadTile({
    required String title,
    required String hintText,
    required String? path,
    required void Function(String) onPathSet,
    required int maxFileSizeMB,
  }) {
    final bool uploaded = path != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: uploaded ? Colors.green.shade600 : Colors.red.shade400, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: uploaded ? Colors.green.shade50 : Colors.red.shade50,
        leading: Icon(uploaded ? Icons.check_circle : Icons.warning, 
                        color: uploaded ? Colors.green.shade700 : Colors.red.shade700),
        title: Text('$title * (Max ${maxFileSizeMB}MB)', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          uploaded ? 'File Selected: $path' : hintText, 
          style: TextStyle(color: uploaded ? Colors.black87 : Colors.red.shade700, fontStyle: uploaded ? FontStyle.normal : FontStyle.italic)),
        // Trailing icon explicitly set to suggest file/folder selection
        trailing: Icon(Icons.folder_open, color: uploaded ? Colors.green.shade700 : Colors.blue.shade800), 
        onTap: () {
          // --- Placeholder for file picker logic ---
          // This simulates a successful file selection/upload
          final fileName = 'uploaded_${title.toLowerCase().replaceAll(' ', '_')}.pdf/jpg';
          setState(() {
            onPathSet(fileName);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title simulated upload successful.'),
              backgroundColor: Colors.blueGrey,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Personal Registration'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      // --- FAB for Submission ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        icon: const Icon(Icons.send),
        label: const Text('Submit Registration'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // --- End FAB ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Name Fields
              _buildTextField(controller: _firstNameController, labelText: 'First Name', icon: Icons.person, validator: (v) => _validateRequired(v, 'First Name')),
              _buildTextField(controller: _middleNameController, labelText: 'Middle Name', icon: Icons.person_outline, isOptional: true, validator: (_) => null),
              _buildTextField(controller: _lastNameController, labelText: 'Last Name', icon: Icons.person, validator: (v) => _validateRequired(v, 'Last Name')),

              // Contact Fields
              _buildTextField(controller: _emailController, labelText: 'College Email ID', icon: Icons.email, validator: _validateEmail),
              _buildTextField(controller: _phoneController, labelText: 'Phone Number', icon: Icons.phone, keyboardType: TextInputType.phone, validator: _validatePhone),

              // Course Selection (Semester / Year)
              _buildDropdown<String>(
                value: _selectedCourse,
                labelText: 'Select Course',
                icon: Icons.school,
                items: _subjectsByCourse.keys.toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                    _selectedDivision = null; // Reset division when course changes
                    _selectedSubject = null; // Reset subject when course changes
                  });
                },
                validator: (v) => _validateRequired(v, 'Course'),
              ),

              // Division Selection (Conditional based on Course)
              _buildDropdown<String>(
                value: _selectedDivision,
                labelText: 'Select Division',
                icon: Icons.class_outlined,
                items: _selectedCourse != null 
                    ? (_selectedCourse!.startsWith('I') ? ['I-A', 'I-B'] : ['II-A', 'II-B'])
                    : [], // Empty if no course selected
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDivision = newValue;
                  });
                },
                validator: (v) => _validateRequired(v, 'Division'),
              ),

              // Subject Selection (Conditional based on Course)
              _buildDropdown<String>(
                value: _selectedSubject,
                labelText: 'Select Subject',
                icon: Icons.book,
                items: _selectedCourse != null ? _subjectsByCourse[_selectedCourse]! : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                  });
                },
                validator: (v) => _validateRequired(v, 'Subject'),
              ),

              const SizedBox(height: 20),
              const Text('Mandatory Document Uploads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
              const Divider(color: Color(0xFF1565C0)),

              // Signature Upload
              _buildFileUploadTile(
                title: 'Upload Signature (Mandatory)',
                hintText: 'Required: Click the folder icon to select your signature file (< 1MB)',
                path: _signaturePath,
                onPathSet: (path) => setState(() => _signaturePath = path),
                maxFileSizeMB: 1,
              ),

              // Photo Upload
              _buildFileUploadTile(
                title: 'Upload Photo (Mandatory)',
                hintText: 'Required: Click the folder icon to select your passport photo file (< 1MB)',
                path: _photoPath,
                onPathSet: (path) => setState(() => _photoPath = path),
                maxFileSizeMB: 1,
              ),

              // Added extra padding so the last element is not hidden by the FAB
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }
}