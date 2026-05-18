// import 'package:flutter/material.dart';
// import 'package:emecexpo/model/conversation_model.dart';
// import 'package:emecexpo/model/scanned_badge_model.dart';
// import 'package:emecexpo/model/message_model.dart';
// import 'package:emecexpo/messages_screen.dart';
// import 'package:provider/provider.dart'; // 💡 Import Provider
// import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import ThemeProvider
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'main.dart';
//
//
// class ConversationsScreen extends StatefulWidget {
//   const ConversationsScreen({super.key});
//
//   @override
//   State<ConversationsScreen> createState() => _ConversationsScreenState();
// }
//
// class _ConversationsScreenState extends State<ConversationsScreen> {
//   late SharedPreferences prefs;
//   List<Conversation> _conversations = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadConversations();
//   }
//
//   void _loadConversations() async {
//     // Simulate fetching conversations from a backend
//     await Future.delayed(const Duration(seconds: 1));
//
//     setState(() {
//       _conversations = [
//         Conversation(
//           participant: ScannedBadge(
//             name: 'Mr Alieu Jagne',
//             title: 'Founder CEO',
//             company: 'LocaleNLP',
//             profilePicturePath: 'assets/profile_alieu.png',
//             companyLogoPath: 'assets/logo_localenlp.png',
//             tags: ['EXHIBITOR'],
//             scanDateTime: DateTime(2025, 4, 15, 18, 14),
//             initials: 'AJ',
//           ),
//           lastMessage: Message(
//             senderId: 'user_me',
//             text: 'Sounds good! Looking forward to it.',
//             timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
//             isMe: true,
//           ),
//         ),
//         Conversation(
//           participant: ScannedBadge(
//             name: 'Dr. Jane Doe',
//             title: 'Head of Research',
//             company: 'Innovate Labs',
//             profilePicturePath: 'assets/profile_jane.png',
//             companyLogoPath: 'assets/logo_innovate.png',
//             tags: ['Speaker'],
//             scanDateTime: DateTime(2025, 4, 16, 10, 30),
//             initials: 'JD',
//           ),
//           lastMessage: Message(
//             senderId: 'Dr. Jane Doe',
//             text: 'I\'ll send you the details shortly.',
//             timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//             isMe: false,
//           ),
//         ),
//         Conversation(
//           participant: ScannedBadge(
//             name: 'Othniel ATSE',
//             title: 'Technical Director',
//             company: 'IMPROTECH',
//             profilePicturePath: 'assets/profile_othniel.png',
//             companyLogoPath: 'assets/logo_improtech.png',
//             tags: ['EXHIBITOR'],
//             scanDateTime: DateTime(2025, 4, 14, 17, 44),
//             initials: 'OA',
//           ),
//           lastMessage: Message(
//             senderId: 'user_me',
//             text: 'Thanks for the presentation!',
//             timestamp: DateTime.now().subtract(const Duration(days: 1)),
//             isMe: true,
//           ),
//         ),
//         Conversation(
//           participant: ScannedBadge(
//             name: 'Ms Zhor Yasmine Mahdi',
//             title: 'Data scientist',
//             company: 'Smartly AI',
//             profilePicturePath: null,
//             companyLogoPath: 'assets/logo_smartlyai.png',
//             tags: ['EXHIBITOR'],
//             scanDateTime: DateTime(2025, 4, 14, 17, 13),
//             initials: 'ZM',
//           ),
//           lastMessage: Message(
//             senderId: 'Ms Zhor Yasmine Mahdi',
//             text: 'Okay, I will check and get back to you.',
//             timestamp: DateTime.now().subtract(const Duration(days: 2)),
//             isMe: false,
//           ),
//         ),
//       ];
//       _isLoading = false;
//     });
//   }
//
//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);
//
//     if (difference.inDays == 0) {
//       return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//       return weekdays[timestamp.weekday - 1];
//     } else {
//       return '${timestamp.day}/${timestamp.month}/${timestamp.year.toString().substring(2,4)}';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 💡 Access the theme provider
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final theme = themeProvider.currentTheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Messages'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Assuming a light icon on a colored AppBar
//           onPressed: () async{
//             prefs = await SharedPreferences.getInstance();
//             prefs.setString("Data", "99");
//             Navigator.pushReplacement(
//                 context, MaterialPageRoute(builder: (context) => WelcomPage()));
//           },
//         ),
//         // ✅ Apply primaryColor from the theme
//         backgroundColor: theme.primaryColor,
//         // ✅ Apply whiteColor for the text and icons
//         foregroundColor: theme.whiteColor,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? Center(
//         child: CircularProgressIndicator(
//           // ✅ Apply secondaryColor from the theme
//           color: theme.secondaryColor,
//         ),
//       )
//           : _conversations.isEmpty
//           ? Center(
//         child: Text(
//           'No conversations yet.',
//           // ✅ Apply a grey color or a color from the theme
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       )
//           : ListView.builder(
//         itemCount: _conversations.length,
//         itemBuilder: (context, index) {
//           final conversation = _conversations[index];
//           return InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => MessagesScreen(
//                     recipientBadge: conversation.participant,
//                   ),
//                 ),
//               );
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 28,
//                     // ✅ Apply blackColor with opacity for the background
//                     backgroundColor: theme.blackColor.withOpacity(0.05),
//                     child: conversation.participant.profilePicturePath != null && conversation.participant.profilePicturePath!.isNotEmpty
//                         ? ClipOval(
//                       child: Image.asset(
//                         conversation.participant.profilePicturePath!,
//                         fit: BoxFit.cover,
//                         width: 56,
//                         height: 56,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Center(
//                             child: Text(
//                               conversation.participant.initials,
//                               // ✅ Apply a grey color or a color from the theme
//                               style: TextStyle(fontSize: 20, color: Colors.grey),
//                             ),
//                           );
//                         },
//                       ),
//                     )
//                         : Center(
//                       child: Text(
//                         conversation.participant.initials,
//                         // ✅ Apply a grey color or a color from the theme
//                         style: TextStyle(fontSize: 20, color: Colors.grey),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16.0),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 conversation.participant.name,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   // ✅ Apply blackColor from the theme
//                                   color: theme.blackColor,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Text(
//                               _formatTimestamp(conversation.lastMessage.timestamp),
//                               style: TextStyle(
//                                 // ✅ Apply a grey color or a color from the theme
//                                 color: Colors.grey,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4.0),
//                         Text(
//                           conversation.lastMessage.text,
//                           style: TextStyle(
//                             // ✅ Apply blackColor from the theme
//                             color: theme.blackColor,
//                             fontSize: 14,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }