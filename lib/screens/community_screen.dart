// community_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Initialize Firebase instances (Assuming these are available globally or passed in)
// NOTE: Ensure these are correctly initialized in your main application flow.
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _messageController = TextEditingController();

  // Function to send a message to Firestore
  Future<void> _sendMessage() async {
    final user = _auth.currentUser;
    final messageText = _messageController.text.trim();

    if (user != null && messageText.isNotEmpty) {
      // Use the facultyName/code stored in displayName for the sender name
      final senderName = user.displayName ?? 'Unknown Faculty';
      
      // All messages are sent to the same 'community_chat' collection
      await _firestore.collection('community_chat').add({
        'text': messageText,
        'senderId': user.uid,
        'senderName': senderName,
        'timestamp': Timestamp.now(), // Use server timestamp for ordering
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Community Chat'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          // Chat Messages StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Listen to the 'community_chat' collection, ordered by timestamp
              stream: _firestore
                  .collection('community_chat')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading messages: ${snapshot.error}'),
                  );
                }

                // Map Firestore documents to a list of Widgets (Chat Bubbles)
                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = messages.map((messageDoc) {
                  final data = messageDoc.data() as Map<String, dynamic>;
                  final messageText = data['text'] as String;
                  final senderName = data['senderName'] as String;
                  final senderId = data['senderId'] as String;
                  final currentUser = _auth.currentUser;
                  
                  // Determine if the message belongs to the current user
                  final isMe = currentUser != null && senderId == currentUser.uid;

                  return MessageBubble(
                    sender: senderName,
                    text: messageText,
                    isMe: isMe,
                  );
                }).toList();

                return ListView(
                  reverse: true, // Show latest messages at the bottom
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  children: messageWidgets,
                );
              },
            ),
          ),

          // Message Input Area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.indigo),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.indigo, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2.0),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(), // Allows sending with keyboard enter
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.indigo,
                  elevation: 0,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widget for Chat Bubbles ---

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          // Sender Name
          Text(
            isMe ? 'You' : sender,
            style: TextStyle(
              fontSize: 12.0,
              color: isMe ? Colors.indigo : Colors.black54,
              fontWeight: FontWeight.bold
            ),
          ),
          // Message Container
          Material(
            borderRadius: BorderRadius.only(
              topLeft: isMe ? const Radius.circular(30.0) : const Radius.circular(0),
              topRight: isMe ? const Radius.circular(0) : const Radius.circular(30.0),
              bottomLeft: const Radius.circular(30.0),
              bottomRight: const Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe ? Colors.indigo : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}