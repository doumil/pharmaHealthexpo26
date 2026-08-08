// lib/main/welcome_logic.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:pharma_health_expo/model/user_model.dart';
import 'package:pharma_health_expo/login_screen.dart';
import 'package:pharma_health_expo/constants.dart';
import 'package:pharma_health_expo/api_services/notification_api_service.dart';
import 'package:pharma_health_expo/api_services/notification_timer.dart';
import 'package:pharma_health_expo/main/welcome_page.dart'; // 👈 استدعاء welcome_page للرجوع للـ Home
import '../main.dart'; // للوصول لـ notificationCountNotifier

class WelcomeLogic {

  // جلب العداد فالبداية
  static Future<void> fetchAndSyncBadgeImmediately() async {
    try {
      int initialCount = await NotificationApiService.getUnreadCount();
      notificationCountNotifier.value = initialCount;
      await AppBadgePlus.updateBadge(initialCount);
    } catch (e) {
      debugPrint("⚠️ Error fetching initial unread count: $e");
    }
  }

  // تهيئة اليوزر والبيانات
  static Future<User?> initializeUserAndLoadData(BuildContext context, User? initialWidgetUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? loggedInUser = initialWidgetUser;

    if (loggedInUser == null) {
      final String? userJsonString = prefs.getString('currentUserJson');
      if (userJsonString != null) {
        try {
          final Map<String, dynamic> userMap = json.decode(userJsonString);
          loggedInUser = User.fromJson(userMap);
        } catch (e) {
          loggedInUser = null;
        }
      }
    }

    try {
      await NotificationApiService.initAndSendFcmToken();
      int unreadCount = await NotificationApiService.getUnreadCount();
      notificationCountNotifier.value = unreadCount;
      await AppBadgePlus.updateBadge(unreadCount);
    } catch (e) {
      debugPrint("Error auto-sending FCM token: $e");
    }

    return loggedInUser;
  }

  // عملية تسجيل الخروج (ترجع دابا للـ Home كـ Guest)
  static Future<void> performLogout(BuildContext context) async {
    NotificationTimer.stop();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');
    notificationCountNotifier.value = 0;
    try { await AppBadgePlus.updateBadge(0); } catch (_) {}

    if (context.mounted) {
      // 👈 التعديل هنا: الرجوع مباشرة لصفحة WelcomPage (الـ Home) كزائر عوض LoginScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  // التحقق من التسجيل قبل فتح الصفحات المحمية وإظهار الـ Popup
  static void navigateToSectionProtected({
    required BuildContext context,
    required DrawerSections section,
    required GlobalKey<ScaffoldState> scaffoldKey,
    required Function(DrawerSections) onNavigateCallback,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');

    List<DrawerSections> protectedSections = [
      DrawerSections.myProfile,
      DrawerSections.myBadge,
      DrawerSections.scannedBadges,
      DrawerSections.myAgenda,
      DrawerSections.networking,
    ];

    if (protectedSections.contains(section) && (authToken == null || authToken.isEmpty)) {
      if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
        Navigator.pop(context);
      }
      showLoginRequiredDialog(context);
    } else {
      onNavigateCallback(section);
    }
  }

  // عرض الـ Popup ديال Login
  static void showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text('You need to log in or sign up to access this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004B9F)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login / Register', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}