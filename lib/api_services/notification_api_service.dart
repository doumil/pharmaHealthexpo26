// lib/api_services/notification_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    final token = prefs.getString('authToken');
    debugPrint("TRACE: _getAuthToken -> ${token != null ? "Found (Length: ${token.length})" : "NULL"}");
    return token;
  }

  static Future<void> _handleTokenExpiration(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      debugPrint("TRACE: Token expired or unauthorized (401/403). Clearing preferences.");
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return;
    }
    try {
      final data = json.decode(response.body);
      if (data is Map && (data["error"] == "TOKEN_EXPIRED" || data["message"]?.toString().contains("expired") == true)) {
        debugPrint("TRACE: Token expired detected from body. Clearing preferences.");
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    } catch (_) {}
  }

  // 🔔 Talab izin notifications mn user b tariqa ijbariya (Force Permission)
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint("TRACE: Notification permission status: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint("TRACE: User granted notification permission.");
        await initAndSendFcmToken();
        return true;
      } else {
        debugPrint("TRACE: ❌ User declined notification permission.");
        if (context.mounted) {
          _showPermissionDialog(context);
        }
        return false;
      }
    } catch (e) {
      debugPrint("TRACE: ❌ Error requesting notification permission: $e");
      return false;
    }
  }

  // Dialog kay 3awd ydir prompt ila rafd l'user al-izin
  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Tafyiil Al-Ishaarat"),
        content: const Text("Marjou tafyiil al-ishaarat likay tasilaka akher al-mustajadāt wal-tanbihat al-muhimmada al-khaassa bil-ma3rid."),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await requestNotificationPermission(context);
            },
            child: const Text("Mowafaq, Tafyiil"),
          ),
        ],
      ),
    );
  }

  static Future<void> initAndSendFcmToken() async {
    try {
      debugPrint("TRACE: === START initAndSendFcmToken ===");
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        debugPrint("TRACE: FCM Token fetched successfully -> $fcmToken");

        String deviceType = 'android';
        if (!kIsWeb && Platform.isIOS) {
          deviceType = 'ios';
        }

        await sendFcmTokenToServer(fcmToken, deviceType);
      } else {
        debugPrint("TRACE: ⚠️ FCM Token from Firebase is NULL!");
      }
    } catch (e) {
      debugPrint("TRACE: ❌ Error in initAndSendFcmToken: $e");
    }
  }

  static Future<bool> sendFcmTokenToServer(String fcmToken, String deviceType) async {
    final Uri uri = Uri.parse('$_baseUrl/fcm-token');
    debugPrint("TRACE: Sending FCM token to URL: $uri");

    final String? authToken = await _getAuthToken();

    if (authToken == null) {
      debugPrint("TRACE: ⚠️️ AuthToken is NULL! FCM token NOT sent to server because user is not authenticated yet.");
      return false;
    }

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

      debugPrint("TRACE: FCM Token API Response Status: ${response.statusCode}");
      debugPrint("TRACE: FCM Token API Response Body: ${response.body}");

      await _handleTokenExpiration(response);

      final responseData = json.decode(response.body);
      bool isSuccess = response.statusCode == 200 && responseData['success'] == true;
      debugPrint("TRACE: FCM Token registered on server successfully: $isSuccess");
      return isSuccess;
    } catch (e) {
      debugPrint("TRACE: ❌ Exception in sendFcmTokenToServer: $e");
      return false;
    }
  }

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