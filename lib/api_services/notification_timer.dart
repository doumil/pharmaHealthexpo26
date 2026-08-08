// lib/services/notification_timer.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:pharma_health_expo/api_services/notification_api_service.dart';
import 'package:pharma_health_expo/model/notification_model.dart';

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

        // 2. إذا كان العدد الجديد في السيرفر أكبر من القيمة اللي كاينة في التطبيق، معناه كاين إشعار جديد
        if (serverCount > countNotifier.value) {
          try {
            // 3. جلب قائمة الإشعارات باش ناخدو آخر إشعار وصل ونعرضوه في البار
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

              // 4. إظهار الإشعار في البار ديال التليفون مع إعطاء id فريد
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
            debugPrint("⚠️ Error fetching latest notification details for status bar: $e");
          }
        }

        // 5. بغض النظر واش كاين إشعار جديد ولا لا، كنخليو العداد والـ Badge يطابقو ديما السيرفر 100%
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
      }
    });

    debugPrint("✅ NotificationTimer started successfully.");
  }

  /// إيقاف الـ Timer (عند تسجيل الخروج مثلاً)
  static void stop() {
    _timer?.cancel();
    _timer = null;
    debugPrint("🛑 NotificationTimer stopped.");
  }
}