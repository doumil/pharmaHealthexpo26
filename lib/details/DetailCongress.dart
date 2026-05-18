// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:badges/badges.dart' as badges;
// //import 'package:flutter_app_badger/flutter_app_badger.dart'; // UPDATED: Correct package import
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// // Import your custom models
// import 'package:emecexpo/model/user_model.dart';
// import 'package:emecexpo/model/notification_model.dart';
//
// // Import your custom screens and services
// import 'package:emecexpo/login_screen.dart';
// import 'package:emecexpo/home_screen.dart';
// import 'package:emecexpo/my_drawer_header.dart';
// import 'package:emecexpo/services/local_notification_service.dart';
// import 'package:emecexpo/my_profile_screen.dart';
//
// // IMPORTANT: Ensure these files exist in your project in the specified paths!
// import 'package:emecexpo/app_user_guide_screen.dart';
// import 'package:emecexpo/my_badge_screen.dart';
// import 'package:emecexpo/favourites_screen.dart';
// import 'package:emecexpo/scanned_badges_screen.dart';
// import 'package:emecexpo/conversations_screen.dart';
// import 'package:emecexpo/meeting_ratings_screen.dart';
// import 'package:emecexpo/Busniess%20Safe.dart';
// import 'package:emecexpo/Congress.dart';
// import 'package:emecexpo/Contact.dart';
// import 'package:emecexpo/Exhibitors.dart';
// import 'package:emecexpo/Expo%20Floor%20Plan.dart';
// import 'package:emecexpo/Food.dart';
// import 'package:emecexpo/How%20to%20get%20there.dart';
// import 'package:emecexpo/Information.dart';
// import 'package:emecexpo/Media%20Partners.dart';
// import 'package:emecexpo/News.dart';
// import 'package:emecexpo/Notifications.dart';
// import 'package:emecexpo/Official%20events.dart';
// import 'package:emecexpo/Settings.dart';
// import 'package:emecexpo/Social%20Media.dart';
// import 'package:emecexpo/Speakers.dart';
// import 'package:emecexpo/details/DetailCongress.dart';
// import 'package:emecexpo/details/DetailNetworkin.dart';
// import 'package:emecexpo/partners.dart';
// import 'package:emecexpo/product.dart';
// import 'package:emecexpo/Activities.dart';
// import 'package:emecexpo/My%20Agenda.dart';
// import 'package:emecexpo/Suporting%20Partners.dart';
// import 'package:emecexpo/details/CongressMenu.dart';
// import 'package:emecexpo/Schedule.dart';
// import 'package:emecexpo/networking.dart';
//
//
// // Global ValueNotifier to hold the current notification count for UI updates
// ValueNotifier<int> notificationCountNotifier = ValueNotifier(0);
//
// // GLOBAL LIST FOR NOTIFICATIONS - This is the in-memory source of truth for your notifications
// List<NotifClass> globalLitems = [];
//
// // Global variables for notification details
// var name = "1", date = "1", dtime = "1", discription = "1";
// var fbm = FirebaseMessaging.instance;
//
// // Firebase background message handler (runs in its own isolate)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage event) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${event.messageId}");
//
//   name = event.notification?.title ?? "No Title";
//   date = "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
//   dtime = "${DateTime.now().hour}:${DateTime.now().minute}";
//   discription = event.notification?.body ?? "No Body";
//
//   globalLitems.add(NotifClass(name, date, dtime, discription));
//   print("Background notification received. Total items in globalLitems: ${globalLitems.length}");
// }
//
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//   }
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   NotificationService().initNotification();
//   HttpOverrides.global = MyHttpOverrides();
//
//   await _requestNotificationPermission();
//
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   // --- LOGIN/AUTH CHECK START ---
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   final String? authToken = prefs.getString('authToken');
//   String? userJson = prefs.getString('currentUserJson');
//
//   Widget initialScreen;
//   User? loadedUser;
//
//   if (authToken != null && authToken.isNotEmpty && userJson != null && userJson.isNotEmpty) {
//     try {
//       loadedUser = User.fromJson(json.decode(userJson));
//     } catch (e) {
//       print("Error parsing stored user JSON in main: $e");
//       await prefs.remove('authToken');
//       await prefs.remove('currentUserJson');
//       loadedUser = null;
//     }
//   }
//
//   if (loadedUser != null && authToken != null && authToken.isNotEmpty) {
//     initialScreen = WelcomPage(user: loadedUser, initialDrawerSection: DrawerSections.myProfile);
//   } else {
//     initialScreen = const LoginScreen();
//   }
//   // --- LOGIN/AUTH CHECK END ---
//
//
//   globalLitems = [
//     NotifClass(
//       "Welcome to EMEC EXPO!",
//       "01 Jan",
//       "09:00",
//       "Get ready for an amazing experience. Explore exhibitors and sessions.",
//     ),
//     NotifClass(
//       "New Exhibitor Alert",
//       "05 Jan",
//       "10:00",
//       "TechInnovate Inc. has just joined! Visit their booth at Stand 23.",
//     ),
//     NotifClass(
//       "Upcoming Session Reminder",
//       "09 Jun",
//       "14:30",
//       "Don't miss the 'Future of AI' panel discussion today at Hall B, Room 7. Join us live!",
//     ),
//     NotifClass(
//       "Networking Event Tonight",
//       "10 Jun",
//       "18:00",
//       "Join us for a casual networking reception at the Grand Ballroom.",
//     ),
//   ];
//   notificationCountNotifier.value = globalLitems.length;
//
//   // UPDATED: notification badge logic for app icon
// /*  notificationCountNotifier.addListener(() async {
//     int currentCount = notificationCountNotifier.value;
//     if (currentCount > 0) {
//       await FlutterAppBadger.updateBadgeCount(currentCount);
//       print("App icon badge updated to: $currentCount");
//     } else {
//       await FlutterAppBadger.removeBadge();
//       print("App icon badge removed.");
//     }
//   });*/
//
// /*  WidgetsBinding.instance.addPostFrameCallback((_) async {
//     if (notificationCountNotifier.value > 0) {
//       await FlutterAppBadger.updateBadgeCount(notificationCountNotifier.value);
//     } else {
//       await FlutterAppBadger.removeBadge();
//     }
//   });*/
//
//   runApp(MyApp(initialScreen: initialScreen));
// }
//
// Future<void> _requestNotificationPermission() async {
//   final status = await Permission.notification.status;
//   if (status.isDenied) {
//     print("Notification permission denied. Requesting...");
//     await Permission.notification.request();
//   } else if (status.isPermanentlyDenied) {
//     print("Notification permission permanently denied. Opening settings.");
//     openAppSettings();
//   }
// }
//
// void onMessage(){
//   FirebaseMessaging.onMessage.listen((event) async {
//     String? title = event.notification?.title;
//     String? body = event.notification?.body;
//
//     String current_date = "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
//     String current_dtime = "${DateTime.now().hour}:${DateTime.now().minute}";
//
//     if (title != null && body != null) {
//       globalLitems.add(NotifClass(title, current_date, current_dtime, body));
//       notificationCountNotifier.value = globalLitems.length;
//       print("Foreground notification received and added. Badge count: ${notificationCountNotifier.value}");
//     }
//
//     NotificationService().NotifDataChanged(title: title, body: body);
//     print("FCM Foreground Notification Title: ${event.notification?.title}");
//     print("FCM Foreground Notification Body: ${event.notification?.body}");
//   });
// }
//
// class MyApp extends StatelessWidget {
//   final Widget initialScreen;
//
//   const MyApp({Key? key, required this.initialScreen}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: initialScreen,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xff261350),
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );
//   }
// }
//
// class WelcomPage extends StatefulWidget {
//   final User user;
//   final DrawerSections initialDrawerSection;
//
//   const WelcomPage({Key? key, required this.user, this.initialDrawerSection = DrawerSections.home}) : super(key: key);
//
//   @override
//   _WelcomPageState createState() => _WelcomPageState();
// }
//
// class _WelcomPageState extends State<WelcomPage> {
//   var currentPage = DrawerSections.home;
//   var _data = "";
//   late SharedPreferences prefs;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   late User _loggedInUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _loggedInUser = widget.user;
//     currentPage = widget.initialDrawerSection;
//
//     _loadDataFromPrefs();
//     _goTo_notification_back();
//     onMessage();
//   }
//
//   Future<void> _loadDataFromPrefs() async {
//     prefs = await SharedPreferences.getInstance();
//     _data = (prefs.getString("Data") ?? '');
//     print("-------------Data from prefs: $_data------------------");
//     setState(() {
//       if (_data == "1") {
//         currentPage = DrawerSections.exhibitors;
//       } else if (_data == "2") {
//         currentPage = DrawerSections.congressmenu;
//       } else if (_data == "3") {
//         currentPage = DrawerSections.business;
//       } else if (_data == "4") {
//         currentPage = DrawerSections.notifications;
//         notificationCountNotifier.value = 0;
//       } else if (_data == "5") {
//         currentPage = DrawerSections.congressmenu;
//       } else if (_data == "6") {
//         currentPage = DrawerSections.detailexhib;
//       } else if (_data == "7") {
//         currentPage = DrawerSections.detailcongress;
//       } else if (_data == "8") {
//         currentPage = DrawerSections.DetailNetworkin;
//       } else if (_data == "9") {
//         currentPage = DrawerSections.networking;
//       }
//     });
//   }
//
//   _goTo_notification_back() {
//     FirebaseMessaging.onMessageOpenedApp.listen((event) async {
//       prefs = await SharedPreferences.getInstance();
//       prefs.setString("Data", "4");
//       notificationCountNotifier.value = 0;
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => WelcomPage(user: _loggedInUser, initialDrawerSection: DrawerSections.notifications)));
//     });
//   }
//
//   int _getBottomNavIndexForBottomNav() {
//     if (currentPage == DrawerSections.home) {
//       return 0;
//     } else if (currentPage == DrawerSections.notifications) {
//       return 1;
//     } else if (currentPage == DrawerSections.settings) {
//       return 2;
//     }
//     return 0;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Widget container;
//
//     if (currentPage == DrawerSections.home) {
//       container = HomeScreen(user: _loggedInUser);
//     } else if (currentPage == DrawerSections.networking) {
//       container = NetworkinScreen();
//     } else if (currentPage == DrawerSections.myAgenda) {
//       container = MyAgendaScreen();
//     } else if (currentPage == DrawerSections.congress) {
//       container = CongressScreen();
//     } else if (currentPage == DrawerSections.speakers) {
//       container = SpeakersScreen();
//     } else if (currentPage == DrawerSections.officialEvents) {
//       container = OfficialEventsScreen();
//     } else if (currentPage == DrawerSections.partners) {
//       container = PartnersScreen();
//     } else if (currentPage == DrawerSections.exhibitors) {
//       container = ExhibitorsScreen();
//     } else if (currentPage == DrawerSections.eFP) {
//       container = EFPScreen();
//     } else if (currentPage == DrawerSections.supportingP) {
//       container = SupportingPScreen();
//     } else if (currentPage == DrawerSections.mediaP) {
//       container = MediaPScreen();
//     } else if (currentPage == DrawerSections.socialM) {
//       container = SocialMScreen();
//     } else if (currentPage == DrawerSections.contact) {
//       container = ContactScreen();
//     } else if (currentPage == DrawerSections.information) {
//       container = InformationScreen();
//     } else if (currentPage == DrawerSections.schedule) {
//       container = SchelduleScreen();
//     } else if (currentPage == DrawerSections.getThere) {
//       container = GetThereScreen();
//     } else if (currentPage == DrawerSections.notifications) {
//       container = NotificationsScreen();
//     }
// /*    else if (currentPage == DrawerSections.settings) {
//       container = SettingsScreen();
//     }*/
//     else if (currentPage == DrawerSections.congressmenu) {
//       container = CongressMenu();
//     } else if (currentPage == DrawerSections.DetailNetworkin) {
//       container = DetailNetworkinScreen();
//     } else if (currentPage == DrawerSections.detailexhib) {
//       container = ExhibitorsScreen();
//     }
//     else if (currentPage == DrawerSections.appUserGuide) {
//       container = const AppUserGuideScreen();
//     } else if (currentPage == DrawerSections.myProfile) {
//       container = MyProfileScreen(user: _loggedInUser);
//     } else if (currentPage == DrawerSections.myBadge) {
//       container = const MyBadgeScreen();
//     } else if (currentPage == DrawerSections.favourites) {
//       container = const FavouritesScreen();
//     }
// /*    else if (currentPage == DrawerSections.scannedBadges) {
//       container = const ScannedBadgesScreen();
//     } */
//     else if (currentPage == DrawerSections.messages) {
//       container = const ConversationsScreen();
//     } else if (currentPage == DrawerSections.meetingRatings) {
//       container = const MeetingRatingsScreen();
//     } else if (currentPage == DrawerSections.products) {
//       container = ProductScreen();
//     } else if (currentPage == DrawerSections.congresses) {
//       container = CongressScreen();
//     } else if (currentPage == DrawerSections.sponsors) {
//       container = SupportingPScreen();
//     }
//     else {
//       container = HomeScreen(user: _loggedInUser);
//     }
//
//     return Scaffold(
//       key: _scaffoldKey,
//       body: container,
//       endDrawer: Drawer(
//         child: SingleChildScrollView(
//           child: Container(
//             color: const Color(0xff261350),
//             child: Column(
//               children: [
//                 MyHeaderDrawer(user: _loggedInUser),
//                 const SizedBox(height: 5.0),
//                 MyDrawerList(),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: ValueListenableBuilder<int>(
//               valueListenable: notificationCountNotifier,
//               builder: (context, count, child) {
//                 return badges.Badge(
//                   showBadge: count > 0,
//                   badgeContent: Text(
//                     count.toString(),
//                     style: const TextStyle(color: Colors.white, fontSize: 10),
//                   ),
//                   badgeStyle: const badges.BadgeStyle(
//                     badgeColor: Colors.red,
//                     padding: EdgeInsets.all(5),
//                   ),
//                   position: badges.BadgePosition.topEnd(top: -10, end: -12),
//                   child: const Icon(Icons.notifications),
//                 );
//               },
//             ),
//             label: 'Notifications',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.menu),
//             label: 'Menu',
//           ),
//         ],
//         currentIndex: _getBottomNavIndexForBottomNav(),
//         selectedItemColor: const Color(0xff00c1c1),
//         unselectedItemColor: Colors.white,
//         backgroundColor: const Color(0xff261350),
//         onTap: (index) async {
//           setState(() {
//             if (index == 0) {
//               currentPage = DrawerSections.home;
//             } else if (index == 1) {
//               currentPage = DrawerSections.notifications;
//               notificationCountNotifier.value = 0;
//             } else if (index == 2) {
//               _scaffoldKey.currentState?.openEndDrawer();
//             }
//           });
//         },
//       ),
//     );
//   }
//
//   Widget MyDrawerList() {
//     return Container(
//       padding: const EdgeInsets.only(top: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           menuItem(1, "Home", Icons.home_outlined, currentPage == DrawerSections.home),
//           menuItem(21, "Notifications", Icons.notifications_none, currentPage == DrawerSections.notifications),
//
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Text(
//               "EVENT INFORMATION",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           menuItem(24, "App User Guide", Icons.menu_book, currentPage == DrawerSections.appUserGuide),
//           menuItem(11, "Floor Plan", Icons.location_on_outlined, currentPage == DrawerSections.eFP),
//           menuItem(7, "Exhibitors", Icons.work_outline, currentPage == DrawerSections.exhibitors),
//           menuItem(25, "Products", Icons.shopping_bag_outlined, currentPage == DrawerSections.products),
//           menuItem(4, "Speakers", Icons.speaker_group_outlined, currentPage == DrawerSections.speakers),
//           menuItem(26, "Congresses", Icons.account_balance, currentPage == DrawerSections.congresses),
//           menuItem(27, "Sponsors", Icons.star_border, currentPage == DrawerSections.sponsors),
//           menuItem(6, "Partners", Icons.handshake, currentPage == DrawerSections.partners),
//
//           const Divider(color: Colors.white24, height: 20),
//
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Text(
//               "ACCOUNT",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           menuItem(28, "My Profile", Icons.person_outline, currentPage == DrawerSections.myProfile),
//           menuItem(29, "My Badge", FontAwesomeIcons.idBadge, currentPage == DrawerSections.myBadge),
//           menuItem(30, "Favourites", Icons.favorite_border, currentPage == DrawerSections.favourites),
//           menuItem(31, "Scanned Badges", Icons.qr_code_scanner, currentPage == DrawerSections.scannedBadges),
//           menuItem(32, "Messages", Icons.message_outlined, currentPage == DrawerSections.messages),
//           menuItem(19, "My Agenda", Icons.calendar_today, currentPage == DrawerSections.myAgenda),
//           menuItem(33, "Meeting ratings", Icons.star_half, currentPage == DrawerSections.meetingRatings),
//           menuItem(2, "Networking", Icons.share_rounded, currentPage == DrawerSections.networking),
//
//           const Divider(color: Colors.white24, height: 20),
//
//           menuItem(15, "Contact", Icons.contact_phone_outlined, currentPage == DrawerSections.contact),
//           menuItem(18, "How to get there", Icons.map, currentPage == DrawerSections.getThere),
//           menuItem(14, "Social Media", Icons.language, currentPage == DrawerSections.socialM),
//           menuItem(22, "Settings", Icons.settings, currentPage == DrawerSections.settings),
//         ],
//       ),
//     );
//   }
//
//   Widget menuItem(int id, String title, IconData icon, bool selected) {
//     return Material(
//       color: selected ? Colors.white12 : Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           Navigator.pop(context);
//           setState(() {
//             switch (id) {
//               case 1: currentPage = DrawerSections.home; break;
//               case 2: currentPage = DrawerSections.networking; break;
//               case 3: currentPage = DrawerSections.congress; break;
//               case 4: currentPage = DrawerSections.speakers; break;
//               case 6: currentPage = DrawerSections.partners; break;
//               case 7: currentPage = DrawerSections.exhibitors; break;
//               case 11: currentPage = DrawerSections.eFP; break;
//               case 12: currentPage = DrawerSections.supportingP; break;
//               case 14: currentPage = DrawerSections.socialM; break;
//               case 15: currentPage = DrawerSections.contact; break;
//               case 18: currentPage = DrawerSections.getThere; break;
//               case 19: currentPage = DrawerSections.myAgenda; break;
//               case 21: currentPage = DrawerSections.notifications; notificationCountNotifier.value = 0; break;
//               case 22: currentPage = DrawerSections.settings; break;
//
//               case 24: currentPage = DrawerSections.appUserGuide; break;
//               case 25: currentPage = DrawerSections.products; break;
//               case 26: currentPage = DrawerSections.congresses; break;
//               case 27: currentPage = DrawerSections.sponsors; break;
//               case 28: currentPage = DrawerSections.myProfile; break;
//               case 29: currentPage = DrawerSections.myBadge; break;
//               case 30: currentPage = DrawerSections.favourites; break;
//               case 31: currentPage = DrawerSections.scannedBadges; break;
//               case 32: currentPage = DrawerSections.messages; break;
//               case 33: currentPage = DrawerSections.meetingRatings; break;
//
//               case 5: currentPage = DrawerSections.officialEvents; break;
//               case 8: currentPage = DrawerSections.product; break;
//               case 9: currentPage = DrawerSections.act; break;
//               case 10: currentPage = DrawerSections.news; break;
//               case 13: currentPage = DrawerSections.mediaP; break;
//               case 16: currentPage = DrawerSections.information; break;
//               case 17: currentPage = DrawerSections.schedule; break;
//               case 20: currentPage = DrawerSections.business; break;
//
//               default: currentPage = DrawerSections.home;
//             }
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 size: 24,
//                 color: const Color(0xff00c1c1),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// enum DrawerSections {
//   home,
//   myAgenda,
//   networking,
//   congress,
//   speakers,
//   officialEvents,
//   partners,
//   exhibitors,
//   product,
//   act,
//   news,
//   eFP,
//   supportingP,
//   mediaP,
//   socialM,
//   contact,
//   information,
//   schedule,
//   getThere,
//   food,
//   business,
//   notifications,
//   congressmenu,
//   settings,
//   detailexhib,
//   detailcongress,
//   DetailNetworkin,
//
//   appUserGuide,
//   myProfile,
//   myBadge,
//   favourites,
//   scannedBadges,
//   messages,
//   meetingRatings,
//   products,
//   congresses,
//   sponsors,
// }