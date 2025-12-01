import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Assuming this path is correct
import 'notes_screen.dart'; // Assuming this path is correct

// --- CONVERTED TO STATEFULWIDGET ---
class ProfileScreen extends StatefulWidget {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String phoneNo;
  final List<dynamic> assignments; // Dynamic to handle map or string lists

  const ProfileScreen({
    super.key,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNo,
    required this.assignments,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- STATE VARIABLES ---
  bool _isEditing = false;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final middle = (widget.middleName != null && widget.middleName!.isNotEmpty) ? ' ${widget.middleName}' : '';
    final fullName = '${widget.firstName}$middle ${widget.lastName}';

    _fullNameController = TextEditingController(text: fullName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phoneNo);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  // -----------------------

  // --- Toggle Editing State and Save Logic ---
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
    if (!_isEditing) {
      _saveDetails();
    }
  }

  void _saveDetails() {
    // 1. Database Update (Simulated): Send updated data to your backend
    //    * Full Name: _fullNameController.text
    //    * Phone: _phoneController.text
    
    // Note on Email: Since Email is usually the primary key, changing it often requires
    // Firebase re-authentication, hence why it's marked read-only in the UI.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile details updated locally (Name: ${_fullNameController.text}, Phone: ${_phoneController.text}).',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- Logout Method ---
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // Navigate to LoginScreen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out. Try again: $e')),
        );
      }
    }
  }

  // --- Navigation Methods ---
  void _navigateToNotes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotesScreen(),
      ),
    );
  }

  // --- Widget for Editable Details (TextFormField) ---
  Widget _buildEditableDetail({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    bool isEditable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.indigo.shade600),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          TextFormField(
            controller: controller,
            readOnly: !_isEditing || !isEditable,
            keyboardType: title == 'Phone Number' ? TextInputType.phone : TextInputType.text,
            style: TextStyle(
              fontSize: 18,
              color: isEditable ? Colors.black : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.only(left: 35, top: 8, bottom: 8),
              border: InputBorder.none,
              hintText: 'Enter $title',
              filled: _isEditing && isEditable,
              fillColor: isEditable ? Colors.indigo.shade50.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  // --- Widget for Assignment Tile ---
  Widget _buildAssignmentTile({
    required String className,
    required String division,
    required String subject,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject: $subject',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Class: $className | Division: $division',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final displayFirstName = widget.firstName;

    // IMPORTANT: Since you defined an AppBar here, your HomeScreen's BottomNavigationBar
    // logic needs to handle this. If the HomeScreen is NOT conditionally showing the 
    // AppBar, the navigation back to Home (VerticalTimeline) might look odd. 
    // If this is a bottom navigation tab, typically the AppBar is omitted here 
    // and handled by the parent Scaffold, but since you added it, I'm keeping it.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // 1. Notes Icon
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            onPressed: () => _navigateToNotes(context),
            tooltip: 'My Notes',
          ),
          // 2. Edit/Save Icon (Primary Action)
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Profile Header ---
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, $displayFirstName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 30, thickness: 1),

            // --- Contact Details Header with Edit/Save Hint ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isEditing ? 'Tap Save to confirm' : 'Tap Edit to modify',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: _isEditing ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- Editable Contact Details ---
            _buildEditableDetail(
              title: 'Full Name',
              controller: _fullNameController,
              icon: Icons.badge,
            ),
            // Email is Read-Only
            _buildEditableDetail(
              title: 'Email ID',
              controller: _emailController,
              icon: Icons.email,
              isEditable: false,
            ),
            _buildEditableDetail(
              title: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone,
            ),

            const Divider(height: 30, thickness: 1),

            // --- Teaching Assignments ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Teaching Assignments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  if (widget.assignments.isEmpty)
                    const Text(
                      'No assignments currently listed.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    )
                  else
                    // Map the dynamic assignments list
                    ...widget.assignments.map((assignment) {
                      if (assignment is Map<String, dynamic> &&
                          assignment.containsKey('class') &&
                          assignment.containsKey('division') &&
                          assignment.containsKey('subject')) 
                      {
                        // Case 1: Assignment is a well-structured Map
                        return _buildAssignmentTile(
                          className: assignment['class'] ?? 'N/A',
                          division: assignment['division'] ?? 'N/A',
                          subject: assignment['subject'] ?? 'N/A',
                        );
                      } else {
                        // Case 2: Assignment is a simple string, attempt to parse
                        final parts = assignment.toString().split(' - ');
                        return _buildAssignmentTile(
                          className: parts.length > 0 ? parts[0] : 'N/A',
                          division: parts.length > 1 ? parts[1] : 'N/A',
                          subject: parts.length > 2 ? parts[2] : assignment.toString(),
                        );
                      }
                    }).toList(),
                ],
              ),
            ),

            // --- Logout Button (centered at bottom) ---
            const SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, size: 40, color: Colors.red),
                    onPressed: () => _logout(context),
                    tooltip: 'Logout',
                  ),
                  const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}