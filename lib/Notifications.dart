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

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = NotificationApiService.fetchNotifications().then((list) async {
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

  // دالة متطورة لتنقية التواريخ المعقدة وتحويلها لصيغة نظيفة ومقروءة
  String _formatDateTime(String date, String dtime) {
    String rawDate = "$date $dtime";

    // محاولة تحويل النص إلى كائن DateTime إذا كان بصيغة ISO (مثل 2026-09-30T...)
    try {
      // دمج التاريخ والوقت أو أخذ الأجزاء الصالحة
      final parsedDate = DateTime.tryParse(date) ?? DateTime.tryParse(dtime);
      if (parsedDate != null) {
        // تنسيق نظيف: اليوم الشهر السنة - الوقت (مثال: 30 Sep 2026, 14:29)
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        String day = twoDigits(parsedDate.day);
        String month = _getMonthName(parsedDate.month);
        String year = parsedDate.parsedYearStr(parsedDate.year);
        String hour = twoDigits(parsedDate.hour);
        String minute = twoDigits(parsedDate.minute);

        if (parsedDate.hour == 0 && parsedDate.minute == 0) {
          return "$day $month $year";
        }
        return "$day $month $year, $hour:$minute";
      }
    } catch (_) {}

    // تنظيف يدوي إذا فشل التحويل التلقائي (إزالة Z, T, كلمة at, والكسور الثوانية)
    rawDate = rawDate.replaceAll('T', ' ');
    rawDate = rawDate.replaceAll('Z', '');
    rawDate = rawDate.replaceAll(RegExp(r'\.\d+'), ''); // إزالة أجزاء الثانية مثل .0000
    rawDate = rawDate.replaceAll(RegExp(r'\bat\b', caseSensitive: false), '');
    rawDate = rawDate.replaceAll(RegExp(r'\s+'), ' ').trim();

    return rawDate.isNotEmpty ? rawDate : "$date $dtime";
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  void _onNotificationTap(NotifClass notification) async {
    if (!notification.isRead) {
      bool success = await NotificationApiService.markAsRead(notification.id!);
      if (success) {
        setState(() {
          notification.isRead = true;
        });

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: theme.whiteColor,
            ),
          ),
          elevation: 0.5,
          centerTitle: false,
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
          foregroundColor: theme.whiteColor,
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
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[400]),
                        Transform.rotate(
                          angle: -0.785398,
                          child: Container(
                            width: 3,
                            height: 70,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No notifications",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You're all caught up!",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            bool hasUnread = notifications.any((n) => !n.isRead);

            return Stack(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.only(bottom: 90, top: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 76, color: Color(0xFFF0F2F5)),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final bool isUnread = !notification.isRead;
                    final formattedDate = _formatDateTime(notification.date, notification.dtime);

                    return InkWell(
                      onTap: () => _onNotificationTap(notification),
                      child: Container(
                        color: isUnread ? theme.primaryColor.withOpacity(0.04) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    'assets/PHARMA-HEALTH-EXPO-ICON-WHITE.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                if (isUnread)
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title.isNotEmpty ? notification.title : notification.name,
                                    style: TextStyle(
                                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.body.isNotEmpty ? notification.body : notification.discription,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isUnread ? Colors.black87 : Colors.grey[700],
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isUnread ? theme.primaryColor : Colors.grey[500],
                                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                if (hasUnread)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
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
                          icon: const Icon(Icons.done_all, size: 20),
                          label: const Text(
                            "Mark all as read",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
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

// Extension صغيرة لاستخراج السنة بشكل صحيح
extension on DateTime {
  String parsedYearStr(int year) => year.toString();
}