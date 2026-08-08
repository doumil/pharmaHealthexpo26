// lib/api_services/notification_timer.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:pharma_health_expo/api_services/notification_api_service.dart';
import 'package:pharma_health_expo/model/notification_model.dart';
import 'package:pharma_health_expo/global/app_config.dart';

import 'local_notification_service.dart';

class NotificationTimer {
  static Timer? _timer;

  /// بدء عملية الفحص الدوري وجلب الإشعارات والـ Badge
  static void start(ValueNotifier<int> countNotifier) {
    stop(); // إيقاف أي تيمر قديم لمنع التكرار

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        // 1. جلب العدد الحقيقي الحالي من الـ API
        int serverCount = await NotificationApiService.getUnreadCount();

        // 2. إيلا رجعت -1 معناها التوكين سالا ف الخلفية
        if (serverCount == -1) {
          debugPrint("🔒 Token expired detected in periodic timer. Forcing logout.");
          await AppConfig.forceLogout();
          stop();
          return;
        }

        // 3. إذا كان العدد الجديد في السيرفر أكبر، معناه كاين إشعار جديد
        if (serverCount > countNotifier.value) {
          try {
            List<NotifClass> notifications = await NotificationApiService.fetchNotifications();

            if (notifications.isNotEmpty) {
              NotifClass latestNotif = notifications.first;

              String title = (latestNotif.title != null && latestNotif.title!.isNotEmpty)
                  ? latestNotif.title!
                  : "New Notification";

              String body = (latestNotif.body != null && latestNotif.body!.isNotEmpty)
                  ? latestNotif.body!
                  : (latestNotif.discription != null && latestNotif.discription!.isNotEmpty)
                  ? latestNotif.discription!
                  : "You have a new unread message.";

              await LocalNotificationService.showNotification(
                title: title,
                body: body,
              );
            } else {
              await LocalNotificationService.showNotification(
                title: "New Notification",
                body: "You have received a new notification.",
              );
            }
          } catch (e) {
            debugPrint("⚠️ Error fetching latest notification details: $e");
          }
        }

        // 4. تحديث العداد والـ Badge
        if (countNotifier.value != serverCount) {
          countNotifier.value = serverCount;
          try {
            await AppBadgePlus.updateBadge(serverCount);
            debugPrint("🔄 Badge & Counter synced with server: $serverCount");
          } catch (e) {
            debugPrint("⚠️ Badge update error: $e");
          }
        }
      } catch (e) {
        debugPrint("⚠️ Periodic notification timer check error: $e");
        if (e.toString().contains("TOKEN_EXPIRED") || e.toString().contains("401")) {
          await AppConfig.forceLogout();
          stop();
        }
      }
    });

    debugPrint("✅ NotificationTimer started successfully.");
  }

  /// إيقاف الـ Timer
  static void stop() {
    _timer?.cancel();
    _timer = null;
    debugPrint("🛑 NotificationTimer stopped.");
  }
}