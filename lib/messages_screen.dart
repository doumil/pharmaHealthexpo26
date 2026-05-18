// lib/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:emecexpo/model/message_model.dart'; // Using your package name
import 'package:emecexpo/model/scanned_badge_model.dart'; // Import ScannedBadge model
import 'package:shared_preferences/shared_preferences.dart';


class MessagesScreen extends StatefulWidget {
  final ScannedBadge recipientBadge; // The person you are messaging

  const MessagesScreen({super.key, required this.recipientBadge});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late SharedPreferences prefs;
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = []; // List to hold chat messages
  final ScrollController _scrollController = ScrollController(); // To scroll to bottom

  @override
  void initState() {
    super.initState();
    // Simulate loading some initial messages with the specific recipient
    _loadDummyMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDummyMessages() {
    setState(() {
      _messages.addAll([
        Message(
          senderId: widget.recipientBadge.name, // Other user's ID
          text: 'Hello ${widget.recipientBadge.name}, how can I help you regarding ${widget.recipientBadge.company}?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isMe: false,
        ),
        Message(
          senderId: 'user_me',
          text: 'Hi, I saw your profile at the event and wanted to connect about ${widget.recipientBadge.tags.first}.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          isMe: true,
        ),
        Message(
          senderId: widget.recipientBadge.name, // Other user's ID
          text: 'Great to hear! What specifically are you interested in discussing?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isMe: false,
        ),
      ]);
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          Message(
            senderId: 'user_me', // Current user is sending
            text: _messageController.text.trim(),
            timestamp: DateTime.now(),
            isMe: true,
          ),
        );
        _messageController.clear();
        _scrollToBottom(); // Scroll to the new message
      });
    }
  }

  void _scrollToBottom() {
    // Use WidgetsBinding.instance.addPostFrameCallback to ensure layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow from image
          onPressed: () {
            Navigator.pop(context); // Goes back to the previous screen (ScannedBadgesScreen)
          },
        ),
        title: Row(
          children: [
            // Display recipient's profile picture or initials
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16, // Adjust size as needed
                backgroundColor: Colors.white.withOpacity(0.2), // Light background for initials
                child: widget.recipientBadge.profilePicturePath != null && widget.recipientBadge.profilePicturePath!.isNotEmpty
                    ? ClipOval(
                  child: Image.asset(
                    widget.recipientBadge.profilePicturePath!,
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          widget.recipientBadge.initials,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Text(
                    widget.recipientBadge.initials,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                widget.recipientBadge.name, // Display recipient's name as title
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff261350),
        foregroundColor: Colors.white,
        actions: const [
          // Three dots menu icon from image
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: message.isMe ? Colors.blueAccent[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10.0,
                            color: message.isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input field
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white, // White background for the input area
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type Message', // Hint text from image
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none, // No border, as seen in image
                      ),
                      filled: true,
                      fillColor: Colors.grey[200], // Light grey background for input field
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (_) => _sendMessage(), // Send on enter key
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent), // Send icon from image
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}