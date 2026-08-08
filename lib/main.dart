// lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'providers/app_config_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/home_provider.dart';
import 'model/user_model.dart';
import 'model/notification_model.dart';
import 'api_services/local_notification_service.dart';
import 'api_services/notification_api_service.dart';
import 'login_screen.dart';

import 'main/main_app.dart';
import 'main/welcome_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 [Background Notification Received]: ${message.messageId}");
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class ConnectivityService with ChangeNotifier {}
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) { return child; }
}

ValueNotifier<int> notificationCountNotifier = ValueNotifier(0);
List<NotifClass> globalLitems = [];
var name = "1", date = "1", dtime = "1", discription = "1";

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("⚠️ Firebase initialization error: $e");
  }

  try {
    await LocalNotificationService.init(notificationCountNotifier);
  } catch (e) {
    debugPrint("⚠️ LocalNotificationService init error: $e");
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  User? initialUser;

  // 👈 جعل الواجهة الأولى الافتراضية ديما هي WelcomPage (الـ Home) كـ Guest
  Widget initialScreen = const WelcomPage();

  // التحقق إيلا كان اليوزر مسجل من قبل وحفظنا البيانات ديالو
  final String? userJson = prefs.getString('currentUserJson');
  if (userJson != null && userJson.isNotEmpty) {
    try {
      initialUser = User.fromJson(json.decode(userJson));
      initialScreen = WelcomPage(user: initialUser);
    } catch (_) {}
  }

  globalLitems = [];
  notificationCountNotifier.value = globalLitems.length;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfigProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}