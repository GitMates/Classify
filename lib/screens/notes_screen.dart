// lib/screens/notes_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Simple Note Model
class Note {
  String title;
  String content;
  DateTime date; // To store creation/last modified date

  Note({required this.title, required this.content, required this.date});
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // In-memory list to store notes
  final List<Note> _notes = []; 

  void _addOrEditNote({Note? existingNote, int? index}) async {
    final TextEditingController _titleController = TextEditingController(text: existingNote?.title);
    final TextEditingController _contentController = TextEditingController(text: existingNote?.content);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more screen space
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter note title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  hintText: 'Write your notes here...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (existingNote == null) {
                      // Add new note
                      _notes.insert(0, Note( // Insert at the start to show latest note first
                        title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
                        content: _contentController.text,
                        date: DateTime.now(),
                      ));
                    } else {
                      // Edit existing note
                      existingNote.title = _titleController.text.isEmpty ? 'Untitled' : _titleController.text;
                      existingNote.content = _contentController.text;
                      existingNote.date = DateTime.now(); // Update date on edit
                    }
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(existingNote == null ? 'Add Note' : 'Save Changes'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notes.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 17, 85, 186)),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note, size: 80, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    'No notes yet!',
                    style: TextStyle(fontSize: 22, color: Colors.blue),
                  ),
                  Text(
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
                  color: const Color.fromARGB(255, 11, 46, 126),
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Tooltip(
                    message: 'Tap to Edit, Long Press to Delete', // Clear instructions
                    child: ListTile( // Changed InkWell to ListTile for better structure
                      contentPadding: const EdgeInsets.all(15.0),
                      title: Text(
                        note.title,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 51, 122, 202),
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
                              color: const Color.fromARGB(255, 16, 103, 180),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            DateFormat('MMMM d, h:mm a').format(note.date), // Added time for clarity
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // 👇 Added trailing icon to hint that action is available
                      trailing: const Icon(Icons.edit_note, color: Colors.blue), 
                      
                      onTap: () => _addOrEditNote(existingNote: note, index: index), // Edit note on tap
                      onLongPress: () => _deleteNote(index), // Delete on long press
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(), // Add new note
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 30),
      ),
      // Mimicking the bottom navigation from your image
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail, color: Colors.blue.shade300),
                Text('Home', style: TextStyle(color: Colors.blue.shade300, fontSize: 12)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder, color: Colors.grey.shade600),
                Text('Folder', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}