import 'package:flutter/material.dart';
import 'package:emecexpo/model/notification_model.dart'; // Import your NotifClass model

class NotificationDetailScreen extends StatelessWidget {
  final NotifClass notification;

  const NotificationDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notification.name),
        centerTitle: true, // Center the title
        backgroundColor: const Color(0xff261350),
        leading: IconButton( // Add a back arrow
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // This pops the NotificationDetailScreen off the navigation stack
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${notification.date} at ${notification.dtime}',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            const Divider(), // Optional: A visual separator
            const SizedBox(height: 15),
            Text(
              notification.discription,
              style: const TextStyle(fontSize: 18, height: 1.5), // Line height for better readability
            ),
          ],
        ),
      ),
    );
  }
}