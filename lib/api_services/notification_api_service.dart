// lib/api_services/notification_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pharma_health_expo/model/notification_model.dart';
import '../global/app_config.dart';

class NotificationApiService {
  static String get _baseUrl => AppConfig.notificationsApiUrl;
  static final String _apiKey = AppConfig.apiKey;

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // دالة مساعدة للتحقق واش الخطأ سببو انتهاء التوكين
  static Future<void> _handleTokenExpiration(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // مسح SharedPreferences بالكامل
      return;
    }
    try {
      final data = json.decode(response.body);
      if (data is Map && (data["error"] == "TOKEN_EXPIRED" || data["message"]?.toString().contains("expired") == true)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // مسح SharedPreferences بالكامل
      }
    } catch (_) {}
  }

  // 1. إرسال FCM Token للسيرفر
  static Future<void> initAndSendFcmToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        debugPrint("DEBUG: FCM Token fetched -> $fcmToken");

        String deviceType = 'android';
        if (!kIsWeb && Platform.isIOS) {
          deviceType = 'ios';
        }

        await sendFcmTokenToServer(fcmToken, deviceType);
      }
    } catch (e) {
      debugPrint("DEBUG: Error in initAndSendFcmToken: $e");
    }
  }

  static Future<bool> sendFcmTokenToServer(String fcmToken, String deviceType) async {
    final Uri uri = Uri.parse('$_baseUrl/fcm-token');
    final String? authToken = await _getAuthToken();

    if (authToken == null) return false;

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'device_type': deviceType,
        }),
      );

      await _handleTokenExpiration(response);

      final responseData = json.decode(response.body);
      return response.statusCode == 200 && responseData['success'] == true;
    } catch (e) {
      return false;
    }
  }

// زد هاد التعديل في fetchNotifications وخلّيها تعتمد على السيرفر
  static Future<List<NotifClass>> fetchNotifications() async {
    final Uri uri = Uri.parse('$_baseUrl/notifications');
    final String? authToken = await _getAuthToken();

    if (authToken == null) return [];

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
          'Authorization': 'Bearer $authToken',
        },
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> notificationsList = responseData['notifications'] ?? [];

        List<NotifClass> list = notificationsList.map((item) => NotifClass.fromMap(item)).toList();
        return list;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 3. جلب عدد الإشعارات غير المقروءة (ترجع -1 إذا انتهى التوكين)
  static Future<int> getUnreadCount() async {
    final Uri uri = Uri.parse('$_baseUrl/notifications/unread-count');
    final String? authToken = await _getAuthToken();

    if (authToken == null) return -1;

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
          'Authorization': 'Bearer $authToken',
        },
      );

      // فحص واش التوكين انتهت صلاحيته
      await _handleTokenExpiration(response);
      if (response.statusCode == 401 || response.statusCode == 403) {
        return -1;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData["error"] == "TOKEN_EXPIRED") {
          return -1;
        }

        if (responseData['success'] == true) {
          int count = responseData['count'] ?? 0;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('unread_notifications_count', count);

          return count;
        }
      }
    } catch (e) {
      debugPrint("DEBUG: Error fetching unread count: $e");
    }

    return -1;
  }

  // 4. تعليم إشعار واحد بأنه مقروء
  static Future<bool> markAsRead(int notificationId) async {
    final Uri uri = Uri.parse('$_baseUrl/notifications/$notificationId/read');
    final String? authToken = await _getAuthToken();

    if (authToken == null) return false;

    try {
      final response = await http.patch(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
          'Authorization': 'Bearer $authToken',
        },
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
    } catch (e) {
      debugPrint("DEBUG: Error marking notification as read: $e");
    }
    return false;
  }

  // 5. تعليم جميع الإشعارات بأنها مقروءة
  static Future<bool> markAllAsRead() async {
    final Uri uri = Uri.parse('$_baseUrl/notifications/read-all');
    final String? authToken = await _getAuthToken();

    if (authToken == null) return false;

    try {
      final response = await http.patch(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
          'Authorization': 'Bearer $authToken',
        },
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
    } catch (e) {
      debugPrint("DEBUG: Error marking all notifications as read: $e");
    }
    return false;
  }
}