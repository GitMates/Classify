// lib/screens/notes_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart'; // **1. ADDED: For permanent storage**
import 'dart:convert'; // For encoding/decoding JSON

// --- Note Model (Updated for Serialization) ---
class Note {
  String title;
  String content;
  DateTime date; // To store creation/last modified date

  Note({required this.title, required this.content, required this.date});
  
  // Convert Note object to JSON map
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    // Store DateTime as a standardized string (ISO 8601)
    'date': date.toIso8601String(), 
  };

  // Create Note object from JSON map
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] as String,
      content: json['content'] as String,
      // Parse the stored string back to DateTime
      date: DateTime.parse(json['date'] as String), 
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = []; 
  static const String _notesKey = 'faculty_portal_notes'; // Key for SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Load notes when the screen initializes
  }

  // --- Persistence Logic ---

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert List<Note> to List<Map<String, dynamic>>
    final jsonList = _notes.map((note) => note.toJson()).toList();
    // Encode the list to a JSON string and save it
    await prefs.setString(_notesKey, jsonEncode(jsonList));
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notesKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        // Decode the JSON string and map back to List<Note>
        _notes = jsonList.map((json) => Note.fromJson(json)).toList();
      });
    }
  }

  // --- CRUD Operations ---

  void _addOrEditNote({Note? existingNote, int? index}) async {
    final TextEditingController _titleController = TextEditingController(text: existingNote?.title);
    final TextEditingController _contentController = TextEditingController(text: existingNote?.content);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white, // Ensure modal background is clean
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existingNote == null ? 'New Note' : 'Edit Note',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: const OutlineInputBorder(),
                  hintText: 'Enter note title',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo.shade700, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: const OutlineInputBorder(),
                  hintText: 'Write your notes here...',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo.shade700, width: 2.0),
                  ),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final title = _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim();
                  final content = _contentController.text;

                  if (content.isEmpty) {
                    Navigator.pop(context); // Do nothing if content is empty
                    return;
                  }

                  setState(() {
                    if (existingNote == null) {
                      // Add new note
                      _notes.insert(0, Note( 
                        title: title,
                        content: content,
                        date: DateTime.now(),
                      ));
                    } else {
                      // Edit existing note
                      existingNote.title = title;
                      existingNote.content = content;
                      existingNote.date = DateTime.now();
                      
                      // Move edited note to the top for visibility
                      _notes.remove(existingNote);
                      _notes.insert(0, existingNote);
                    }
                    _saveNotes(); // **Save to permanent storage**
                  });
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700, // Matched Home Screen color
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(existingNote == null ? 'Add Note' : 'Save Changes', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _deleteNote(int index) {
    final noteToDelete = _notes[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete the note: "${noteToDelete.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notes.removeAt(index);
                _saveNotes(); // **Save changes after deletion**
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted successfully.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- Main Widget Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // **Color matched to Home Screen (white background)**
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text('Notes 📝', 
          style: TextStyle(
            color: Colors.white, // Title color is white on indigo background
            fontSize: 22, 
            fontWeight: FontWeight.bold
          )
        ),
        // **Color matched to Home Screen AppBar**
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note, size: 80, color: Colors.indigo.shade400), // Matched color
                  const SizedBox(height: 10),
                  Text(
                    'No notes yet!',
                    style: TextStyle(fontSize: 22, color: Colors.indigo.shade600),
                  ),
                  const Text(
                    'Tap the + button to add your first note.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  // **Adjusted Card color for better contrast**
                  color: Colors.indigo.shade50, 
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Tooltip(
                    message: 'Tap to Edit, Long Press to Delete', 
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15.0),
                      title: Text(
                        note.title,
                        style: TextStyle(
                          color: Colors.indigo.shade800, // Dark indigo title
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            note.content,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat('MMMM d, yyyy - h:mm a').format(note.date), 
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // 👇 Added explicit Delete button for clarity
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _deleteNote(index), 
                        tooltip: 'Delete Note',
                      ),
                      
                      onTap: () => _addOrEditNote(existingNote: note, index: index), // Edit note on tap
                      // Removed onLongPress since a trailing delete button is clearer
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(), 
        // **Color matched to Home Screen primary color**
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 30),
      ),
      // Removed bottomNavigationBar as it seems to be part of the HomeScreen structure
      // and is not needed for a dedicated Notes screen unless it is intended to be a Tab
    );
}
  }