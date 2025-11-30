import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'dart:convert';

// --- Message Data Model ---
enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType type;

  ChatMessage({required this.text, required this.type});
  
  // Serialization methods
  Map<String, dynamic> toJson() => {
    'text': text,
    'type': type.index,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      type: ChatMessageType.values[json['type'] as int],
    );
  }
}

// --- Chat Session Model ---
class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
  });
  
  // Serialization methods
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final List<dynamic> messageList = json['messages'];
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: messageList.map((m) => ChatMessage.fromJson(m)).toList(),
    );
  }
}

// --- ChatScreen Widget ---
class ChatScreen extends StatefulWidget {
  final String facultyName;

  const ChatScreen({super.key, required this.facultyName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  static const String _sessionHistoryKey = 'chat_sessions_history';

  List<ChatSession> _sessions = [];
  late ChatSession _currentSession;
  bool _isLoading = true; 
  bool _isBotTyping = false; 

  static const List<String> mcaSubjects = [
    'Software Engineering',
    'Applied Maths',
    'C Language',
    'Database Technology',
    'Data Structure',
    'Computer Networks',
    'Cloud Computing',
    'Operating Systems',
    'Web Technologies',
    'Project Management',
  ];


  @override
  void initState() {
    super.initState();
    _loadSessions(); 
  }
  
  // --- PERSISTENCE METHODS (Unchanged) ---
  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_sessionHistoryKey);
    
    if (sessionsJson != null) {
      final List<dynamic> jsonList = jsonDecode(sessionsJson);
      _sessions = jsonList.map((json) => ChatSession.fromJson(json)).toList();
    } 
    
    if (_sessions.isEmpty) {
      _startNewChat(isInitial: true);
    } else {
      _currentSession = _sessions.first;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSessions() async {
    if (!mounted) return;
    
    // Only add the current session to the list if it has more than the initial message
    if (_currentSession.messages.length > 1 && !_sessions.any((s) => s.id == _currentSession.id)) {
      // Ensure the current session is at the start (most recent)
      _sessions.insert(0, _currentSession);
    }
    
    final sessionsJson = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionHistoryKey, sessionsJson);
    debugPrint('Chat sessions saved successfully.');
  }
  // ---------------------------

  // Creates a new chat session
  void _startNewChat({bool isInitial = false}) {
    if (!isInitial && _currentSession.messages.length > 1) {
      _saveSessions(); 
    }
    
    final initialMessage = 'Hi ${widget.facultyName}, I am your Faculty Assistant AI. How can I assist you today?';
    
    final newSession = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Chat',
        messages: [
          ChatMessage(text: initialMessage, type: ChatMessageType.bot),
        ],
      );
    
    setState(() {
      _currentSession = newSession;
      if (!isInitial) {
          Navigator.of(context).pop(); 
      }
    });
  }
  
  // Submits a message and gets a bot response
  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text, type: ChatMessageType.user);

    // 1. Add user message and start typing indicator
    setState(() {
      _currentSession.messages.add(userMessage);
      _isBotTyping = true; 
      // Ensure the session is marked as the current one
      if (_currentSession.messages.length > 1 && !_sessions.any((s) => s.id == _currentSession.id)) {
        _sessions.insert(0, _currentSession);
      }
    });
    
    // 2. Simulate a delay for the bot response
    Future.delayed(const Duration(milliseconds: 700), () {
      _addBotResponse(text);
    });
  }
  
  // Generates a simulated subject-based response
  void _addBotResponse(String userQuery) {
    final lowerQuery = userQuery.toLowerCase();
    String botResponse = 'I cannot find a specific resource on that topic right now. I specialize in the MCA curriculum, such as **Database Technology**, **Networking**, or **Software Engineering**. Can you phrase your query differently?';

    // 1. Core Subjects
    if (lowerQuery.contains('software') || lowerQuery.contains('sdlc') || lowerQuery.contains('agile')) {
      botResponse = 'That falls under **Software Engineering**. The **Waterfall model** is a sequential design process, contrasted with **Agile methodologies** which are iterative and incremental. Which one do you need details on?';
    } else if (lowerQuery.contains('math') || lowerQuery.contains('discrete') || lowerQuery.contains('probability') || lowerQuery.contains('statistics')) {
      botResponse = 'You\'re asking about **Applied Maths**! In the MCA curriculum, this often covers areas like **linear algebra** and **statistical methods** essential for data science and algorithms.';
    } else if (lowerQuery.contains('c language') || lowerQuery.contains('pointer') || lowerQuery.contains('struct')) {
      botResponse = '**C Language** is fundamental. Remember that a **pointer** is a variable that stores the memory address of another variable. They are crucial for dynamic memory allocation.';
    } else if (lowerQuery.contains('database') || lowerQuery.contains('sql') || lowerQuery.contains('query') || lowerQuery.contains('normalization') || lowerQuery.contains('dbms')) {
      botResponse = '**Database Technology** is key. The **third normal form (3NF)** aims to eliminate transitive dependencies, reducing data redundancy. Do you have a specific ER diagram to discuss?';
    } else if (lowerQuery.contains('data structure') || lowerQuery.contains('stack') || lowerQuery.contains('queue') || lowerQuery.contains('algorithm') || lowerQuery.contains('tree')) {
      botResponse = '**Data Structures** are crucial. A **Binary Search Tree (BST)** allows for efficient lookup, insertion, and deletion operations, with an average time complexity of O(log n).';
    } 
    // 2. Advanced Subjects
    else if (lowerQuery.contains('network') || lowerQuery.contains('tcp') || lowerQuery.contains('ip') || lowerQuery.contains('osi')) {
      botResponse = 'You are discussing **Computer Networks**. The **OSI model** is a conceptual framework used to describe the functions of a networking system. It has seven layers, from Physical to Application.';
    } else if (lowerQuery.contains('cloud') || lowerQuery.contains('aws') || lowerQuery.contains('azure') || lowerQuery.contains('saas') || lowerQuery.contains('iaas')) {
      botResponse = '**Cloud Computing** is a hot topic! The three main service models are **SaaS** (Software as a Service), **PaaS** (Platform as a Service), and **IaaS** (Infrastructure as a Service).';
    } else if (lowerQuery.contains('operating system') || lowerQuery.contains('os') || lowerQuery.contains('process') || lowerQuery.contains('thread')) {
      botResponse = 'That is **Operating Systems**. A core function is **process management**, where the OS handles the allocation of resources and scheduling of tasks to the CPU.';
    } else if (lowerQuery.contains('web') || lowerQuery.contains('html') || lowerQuery.contains('css') || lowerQuery.contains('javascript')) {
      botResponse = 'Let\'s talk **Web Technologies**. HTML provides structure, CSS handles presentation, and JavaScript governs behavior and interactivity in modern web applications.';
    } 
    // 3. Management/General
    else if (lowerQuery.contains('project') || lowerQuery.contains('risk') || lowerQuery.contains('scope')) {
      botResponse = '**Project Management** involves balancing scope, time, and cost. Effective risk management requires identifying, assessing, and prioritizing risks.';
    }
    // 4. Greetings
    else if (lowerQuery.contains('hi') || lowerQuery.contains('hello')) {
      botResponse = 'Hello again, ${widget.facultyName}! I am here to help with any MCA subject material you need to review.';
    }
    
    // Logic to save the new message and update session history
    if (_currentSession.title == 'New Chat' && _currentSession.messages.length > 1) {
      _currentSession.title = lowerQuery.length > 20 
          ? '${lowerQuery.substring(0, 20)}...' 
          : lowerQuery.toUpperCase();
    }
    
    setState(() {
      _currentSession.messages.add(ChatMessage(text: botResponse, type: ChatMessageType.bot));
      _isBotTyping = false; // Stop typing indicator
      _saveSessions(); 
    });
  }

  // Switches to an existing chat session
  void _loadSession(ChatSession session) {
    if (_currentSession.id != session.id && _currentSession.messages.length > 1) {
        _saveSessions();
    }
    
    setState(() {
      _currentSession = session;
    });
    Navigator.of(context).pop(); 
  }
  
  // --- NEW WIDGET: TYPING INDICATOR ---
  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Bot Icon (Robot)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.android, color: Colors.white), // The little robot import
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.zero,
                bottomRight: Radius.circular(18),
              ),
            ),
            // The actual indicator
            child: SizedBox(
              width: 20, 
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.indigo.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // --------------------------------------

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Ask about any MCA subject...',
              ),
              // Disable input when bot is typing
              enabled: !_isBotTyping, 
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: _isBotTyping ? Colors.grey : Colors.indigo, // Visual change when disabled
              onPressed: _isBotTyping ? null : () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessage(ChatMessage message) {
    final isUser = message.type == ChatMessageType.user;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isUser) // Bot Avatar with Robot Icon
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.indigo,
                child: const Icon(Icons.android, color: Colors.white), // **Robot Icon**
              ),
            ),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser ? Colors.indigo.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.indigo.shade900 : Colors.black87,
                ),
              ),
            ),
          ),
          
          if (isUser) // User Avatar
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(widget.facultyName[0], style: const TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Combine chat messages with the typing indicator if active
    final List<Widget> chatWidgets = [
      if (_isBotTyping) _buildTypingIndicator(), // Show indicator at the top of the list view
      ..._currentSession.messages.reversed.map((message) => _buildMessage(message)).toList(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Recent Chats',
        ),
        title: Text(_currentSession.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AI Assistant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_box, color: Colors.indigo),
                    onPressed: _startNewChat,
                    tooltip: 'New Chat',
                  ),
                ],
              ),
            ),
            const Divider(),
            
            Expanded(
              child: ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(session.title),
                    selected: session.id == _currentSession.id,
                    onTap: () => _loadSession(session),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      body: Column(
        children: <Widget>[
          // Chat Messages List + Typing Indicator
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: chatWidgets.length, // Use the combined list count
              itemBuilder: (context, index) {
                return chatWidgets[index]; // Use the combined list
              },
            ),
          ),
          const Divider(height: 1.0),
          
          // Text Input Composer
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}