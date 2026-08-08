// lib/notification_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_health_expo/model/notification_model.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotifClass notification;

  const NotificationDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        title: Text(
          notification.name,
          style: TextStyle(color: theme.whiteColor),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.whiteColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
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
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: theme.primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 15),
            Divider(color: theme.primaryColor.withOpacity(0.2)),
            const SizedBox(height: 15),
            Text(
              notification.discription,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}