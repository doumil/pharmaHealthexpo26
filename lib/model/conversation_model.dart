// lib/model/conversation_model.dart
import 'package:emecexpo/model/message_model.dart'; // Import Message model
import 'package:emecexpo/model/scanned_badge_model.dart'; // Import ScannedBadge model

class Conversation {
  final ScannedBadge participant; // The other person in this conversation
  final Message lastMessage;     // The last message exchanged in this conversation

  Conversation({
    required this.participant,
    required this.lastMessage,
  });
}