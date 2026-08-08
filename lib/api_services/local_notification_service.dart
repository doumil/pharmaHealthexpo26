// lib/services/local_notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'notification_api_service.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// تهيئة خدمة الإشعارات المحلية والاستماع لرسائل Firebase في المقدمة
  static Future<void> init(ValueNotifier<int>? countNotifier) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint("🔔 Notification clicked: ${details.payload}");
      },
    );

    // 🚀 الإضافة المهمة: الاستماع للإشعارات فاش كيكون التطبيق محلول (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("📩 [Foreground FCM Received]: ${message.notification?.title}");

      // 1. عرض الإشعار محلياً في البار إذا كان جاي من الـ Payload
      if (message.notification != null) {
        await showNotification(
          title: message.notification?.title ?? "New Notification",
          body: message.notification?.body ?? "You have a new message.",
        );
      }

      // 2. جلب العدد الحقيقي فوراً من السيرفر وتحديث البادج والـ Notifier (بحال 21)
      try {
        int realCount = await NotificationApiService.getUnreadCount();
        if (countNotifier != null) {
          countNotifier.value = realCount;
        }
        await AppBadgePlus.updateBadge(realCount);
        debugPrint("🔄 Real badge & counter updated on foreground push: $realCount");
      } catch (e) {
        debugPrint("⚠️ Error syncing badge on foreground message: $e");
      }
    });
  }

  /// إظهار الإشعار في البار ديال التليفون
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'pharma_notifications_channel',
      'Notifications',
      channelDescription: 'Channel for background app notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_notification',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await _notificationsPlugin.show(
        id: DateTime.now().millisecond,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
      );
      debugPrint("✅ Local notification shown successfully: $title");
    } catch (e) {
      debugPrint("❌ Error showing local notification: $e");
    }
  }
}