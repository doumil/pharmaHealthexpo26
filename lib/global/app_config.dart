// lib/global/app_config.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:pharma_health_expo/login_screen.dart';
import 'package:pharma_health_expo/api_services/notification_timer.dart';
import 'package:pharma_health_expo/main.dart'; // للوصول لـ notificationCountNotifier

// تعريف عام للمفتاح باش ميبقاش يعطي Undefined name في حالة ما كانش مستورد مزيان من main
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppConfig {

  static String editionId = "1133";
  static const String eventId = "1230";
  static const String apiKey = "1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7";

  // ==========================================
  // 🔀 اختار البلاصة اللي بغيت تخدم بيها
  // ==========================================
  //static const String baseUrl = "https://app-buzz-clone-27072026.de.cloud.africsp.com";
  static const String baseUrl = "https://buzzevents.co";
  // ==========================================

  static const String version = "1.0.7";
  static const String registerUrl = "https://badge.pharmahealthexpo.ma";
  static const String logoBaseUrl = "$baseUrl/uploads/";

  static String get appSettingsUrl => "$baseUrl/api/events/$eventId/app-settings";
  static String get loginUrl => "$baseUrl/api/login";
  static String get notificationsApiUrl => "$baseUrl/api";

  // 🔗 روابط الـ API الخاصة بالـ Event مركزة هنا
  static String get eventUrl => "$baseUrl/api/event/$eventId";
  static String get eventActiveEditionUrl => "$baseUrl/api/event/$eventId/edition_active";

  /// 🛡️ دالة عامة للتحقق من الـ Token وإخراج اليوزر إيلا سالا
  static Future<bool> handleApiResponse(dynamic responseBody, BuildContext context) async {
    try {
      Map<String, dynamic> data;

      if (responseBody is String) {
        data = json.decode(responseBody);
      } else if (responseBody is Map<String, dynamic>) {
        data = responseBody;
      } else {
        return false;
      }

      // واش السيرفر صيفط بلي الـ Token سالا؟
      if (data["error"] == "TOKEN_EXPIRED") {
        await forceLogout();
        return true;
      }
    } catch (e) {
      debugPrint("Error checking token expiration: $e");
    }
    return false;
  }

  /// 🚪 عملية الخروج الإجباري ومسح التخزين بدون الحاجة لأي argument
  static Future<void> forceLogout() async {
    NotificationTimer.stop();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');

    notificationCountNotifier.value = 0;
    try {
      await AppBadgePlus.updateBadge(0);
    } catch (_) {}

    // استغلال Global Navigator Key للوصول للـ Navigation من الخلفية بلا context
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please log in again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }
}