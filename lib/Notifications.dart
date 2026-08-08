// lib/notifications_screen.dart
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:pharma_health_expo/model/notification_model.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';
import 'api_services/notification_api_service.dart';
import 'details/notification_detail_screen.dart';
import 'home_screen.dart';
import 'main.dart';
import 'main/welcome_page.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late SharedPreferences prefs;
  late Future<List<NotifClass>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // 🚀 هنا فين كاين السر: جبد اللستة + سيفط جبد العدد الحقيقي من السيرفر مباشرة
  void _loadNotifications() {
    setState(() {
      _notificationsFuture = NotificationApiService.fetchNotifications().then((list) async {
        // طلب العدد الحقيقي مباشرة من API باش مايكونش تفاوت نهائياً
        int realCount = await NotificationApiService.getUnreadCount();
        if (realCount >= 0) {
          notificationCountNotifier.value = realCount;
          try {
            await AppBadgePlus.updateBadge(realCount);
          } catch (e) {
            debugPrint("Failed to update badge: $e");
          }
        }
        return list;
      });
    });
  }

  void _onNotificationTap(NotifClass notification) async {
    if (!notification.isRead) {
      bool success = await NotificationApiService.markAsRead(notification.id!);
      if (success) {
        setState(() {
          notification.isRead = true;
        });

        // 🚀 مور ما تقرأت، عيط فوراً للـ API باش يعطيك العدد الحقيقي الجديد (بلا حَسَاب العياقة ديال -1)
        int realCount = await NotificationApiService.getUnreadCount();
        if (realCount >= 0) {
          notificationCountNotifier.value = realCount;
          try {
            await AppBadgePlus.updateBadge(realCount);
          } catch (e) {
            debugPrint("Failed to update app badge on tap: $e");
          }
        }
      }
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(notification: notification),
      ),
    );
  }

  // قراءة الكل عبر الـ API
  void _markAllAsRead(List<NotifClass> notifications) async {
    bool success = await NotificationApiService.markAllAsRead();

    if (success) {
      setState(() {
        for (var notif in notifications) {
          notif.isRead = true;
        }
      });

      notificationCountNotifier.value = 0;
      try {
        await AppBadgePlus.updateBadge(0);
      } catch (e) {
        debugPrint("Failed to update app badge: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return FadeInDown(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            onPressed: () async {
              prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "99");
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomPage()),
              );
            },
          ),
          backgroundColor: theme.primaryColor,
        ),
        body: FutureBuilder<List<NotifClass>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No notifications found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Check back later for updates!",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            bool hasUnread = notifications.any((n) => !n.isRead);

            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final bool isUnread = !notification.isRead;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: isUnread ? 4 : 1,
                      color: isUnread ? theme.primaryColor.withOpacity(0.06) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: isUnread
                            ? BorderSide(color: theme.primaryColor.withOpacity(0.3), width: 1)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        title: Text(
                          notification.title.isNotEmpty ? notification.title : notification.name,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${notification.date} at ${notification.dtime}\n${notification.body.isNotEmpty ? notification.body : notification.discription}',
                            style: TextStyle(
                              color: isUnread ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: isUnread
                            ? CircleAvatar(
                          radius: 5,
                          backgroundColor: theme.primaryColor,
                        )
                            : const Icon(Icons.check, size: 18, color: Colors.grey),
                        onTap: () => _onNotificationTap(notification),
                      ),
                    );
                  },
                ),

                if (hasUnread)
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAllAsRead(notifications),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.whiteColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.done_all),
                        label: const Text(
                          "Mark all as read",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}