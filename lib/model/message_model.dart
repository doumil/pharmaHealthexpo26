class Message {
  final String senderId; // ID of the sender (e.g., 'user_me', 'other_user_id')
  final String text;
  final DateTime timestamp;
  final bool isMe; // True if the message was sent by the current user

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}