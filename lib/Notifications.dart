// lib/notifications_screen.dart
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:emecexpo/model/notification_model.dart';
import 'package:emecexpo/main.dart';
import 'package:emecexpo/providers/theme_provider.dart'; // Import your ThemeProvider
import 'details/notification_detail_screen.dart';
import 'home_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    // This assumes globalLitems is populated before this screen's initState
    notificationCountNotifier.value = globalLitems.length;
  }

  void _onNotificationTap(int index) async {
    if (index < 0 || index >= globalLitems.length) {
      print("Error: Invalid index tapped: $index");
      return;
    }

    final NotifClass tappedNotification = globalLitems[index];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(notification: tappedNotification),
      ),
    );

    // After popping the detail screen, re-check if the list is still valid
    // This logic ensures the item is removed only if the list hasn't fundamentally changed
    if (index < globalLitems.length && globalLitems[index] == tappedNotification) {
      setState(() {
        globalLitems.removeAt(index);
        notificationCountNotifier.value = globalLitems.length;
      });
      print("Notification at index $index deleted after viewing detail. Badge count: ${notificationCountNotifier.value}");
    } else {
      setState(() {
        notificationCountNotifier.value = globalLitems.length;
      });
      print("List changed or item already removed. Re-evaluating badge count: ${notificationCountNotifier.value}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme from the provider
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return FadeInDown(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          centerTitle: true,
          // 🚀 ADDED: Explicit Back Button
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), // Assuming a light icon on a colored AppBar
            onPressed: () async{
              prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "99");
              Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => WelcomPage()));
            },
          ),
          backgroundColor: theme.primaryColor,
        ),
        body: globalLitems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                "No notifications found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                "Check back later for updates!",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: globalLitems.length,
          itemBuilder: (context, index) {
            final notification = globalLitems[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 3,
              child: ListTile(
                title: Text(notification.name),
                subtitle: Text(
                    '${notification.date} at ${notification.dtime}\n${notification.discription}'),
                isThreeLine: true,
                onTap: () => _onNotificationTap(index),
              ),
            );
          },
        ),
      ),
    );
  }
}