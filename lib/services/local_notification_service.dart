// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import '../My Agenda.dart';
// import '../details/DetailCongress.dart'; // Import your screen
//
// // Define a global navigator key to allow navigation from anywhere in the app.
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   Future<void> initNotification() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('ic_launcher');
//
//     final DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       // onDidReceiveLocalNotification has been removed.
//       // All responses are now handled by onDidReceiveNotificationResponse.
//     );
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//
//     await notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
//         // Correct way to navigate after a notification tap.
//         // Avoid using runApp inside a callback as it reinitializes the entire app.
//         navigatorKey.currentState?.push(
//           MaterialPageRoute(builder: (_) => const DetailCongressScreen(check: false)),
//         );
//       },
//     );
//
//     tz.initializeTimeZones();
//   }
//
//   Future<void> notifdeined() async {
//     await notificationsPlugin.cancelAll();
//   }
//
//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName',
//             importance: Importance.max),
//         iOS: DarwinNotificationDetails());
//   }
//
//   Future<void> showNotification(
//       {int id = 0, String? title, String? body, String? payLoad}) async {
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
//
//   Future<void> NotifDataChanged(
//       {int id = 0, String? title, String? body, String? payLoad}) async {
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
//
//   Future<void> showNotifByDate(
//       {int id = 0,
//         String? title,
//         String? body,
//         String? payLoad,
//         required DateTime date}) async {
//     return notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(date, tz.local),
//       await notificationDetails(),
//       // New required parameter for Android scheduling
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       // The following parameters have been removed and should be deleted
//       // androidAllowWhileIdle: true,
//       // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }