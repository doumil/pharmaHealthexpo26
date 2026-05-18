// /*
// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:emecexpo/services/local_notification_service.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:http/http.dart' as http;
// import 'package:emecexpo/services/onwillpop_services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:app_settings/app_settings.dart';
// //import 'package:flutter_mute/flutter_mute.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({Key? key}) : super(key: key);
//
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   final String serverToken = 'AAAAVy_P_0g:APA91bGckzY8RIWOLFp7TK36FOB4yaJCaQdU-en_Q-BUN2rfiK9bgvZMuEs8HslL7_EGIwW20y9cJISstJmiXvDCq4LridWcWhlDG-YZajFkeFU19v-R-iu8EQHT0F7BdSe6vW0XSLMz';
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   late SharedPreferences prefs;
//   bool isChecked1 = false; // Receive Notification
//   bool isChecked2 = false; // Vibrate
//   // bool isChecked3 = false; // Blink LED (commented out as per original)
//   bool _isEnabled = true; // For controlling Vibrate checkbox state
//
//   @override
//   void initState() {
//     _subscribe();
//     _loadData();
//     super.initState();
//   }
//
//   _loadData() async {
//     prefs = await SharedPreferences.getInstance();
// */
// /*    if (RingerMode.Normal == await FlutterMute.getRingerMode()) {
//       prefs.setBool("isChecked2", false);
//       isChecked2 = false;
//     } else {
//       prefs.setBool("isChecked2", true);
//       isChecked2 = true;
//     }*//*
//
//     bool? ch1 = prefs.getBool("isChecked1");
//     bool? ch2 = prefs.getBool("isChecked2");
//     // bool? ch3 = prefs.getBool("isChecked3");
//
//     setState(() {
//       isChecked1 = ch1 ?? false; // Default to false if null
//       isChecked2 = ch2 ?? false; // Default to false if null
//       // isChecked3 = ch3 ?? false; // Default to false if null
//       _isEnabled = isChecked1; // Vibrate is enabled if Receive Notification is true
//     });
//   }
//
//   */
// /*_onChangedReceiveNotification(bool? value) async {
//     setState(() {
//       isChecked1 = value!;
//       _isEnabled = isChecked1; // Enable/disable vibrate based on receive notifications
//     });
//
//     prefs = await SharedPreferences.getInstance();
//     prefs.setBool("isChecked1", isChecked1);
//     prefs.setBool("isChecked2", isChecked2); // Save vibrate state too
//     // prefs.setBool("isChecked3", isChecked3);
//
//     if (isChecked1) {
//       await FirebaseMessaging.instance.subscribeToTopic("Rec");
//     } else {
//       await FirebaseMessaging.instance.unsubscribeFromTopic("Rec");
//       // If receive notification is off, also turn off vibrate
//       if (isChecked2) {
//         setState(() {
//           isChecked2 = false;
//         });
//         prefs.setBool("isChecked2", false);
//         await FlutterMute.setRingerMode(RingerMode.Normal);
//       }
//     }
//   }*//*
//
//
// */
// /*  _onChangedVibrate(bool? value) async {
//     if (!_isEnabled) return; // Prevent changing if disabled by Receive Notification
//
//     setState(() {
//       isChecked2 = value!;
//     });
//
//     prefs = await SharedPreferences.getInstance();
//     prefs.setBool("isChecked2", isChecked2);
//
//     bool isAccessGranted = await FlutterMute.isNotificationPolicyAccessGranted;
//     if (!isAccessGranted) {
//       await FlutterMute.openNotificationPolicySettings();
//     }
//
//     try {
//       if (isChecked2) {
//         await FlutterMute.setRingerMode(RingerMode.Vibrate);
//         HapticFeedback.vibrate(); // Add haptic feedback for vibrate
//       } else {
//         await FlutterMute.setRingerMode(RingerMode.Normal);
//       }
//     } catch (err) {
//       print(err);
//     }
//   }*//*
//
//
//   Future<bool> _onWillPop() async {
//     return (await showDialog(
//       context: context,
//       builder: (context) => new AlertDialog(
//         title: new Text('Êtes-vous sûr'),
//         content: new Text('Voulez-vous quitter une application'),
//         actions: <Widget>[
//           new TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: new Text('Non'),
//           ),
//           new TextButton(
//             onPressed: () => SystemNavigator.pop(),
//             child: new Text('Oui '),
//           ),
//         ],
//       ),
//     )) ??
//         false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//     OnWillPop on = OnWillPop();
//     return WillPopScope(
//       onWillPop: on.onWillPop1,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Center(child: Text("Settings")),
//           backgroundColor: Color(0xff261350),
//           actions: const <Widget>[],
//           elevation: 0,
//           //leading: const SizedBox.shrink(),
//         ),
//         body: FadeInDown(
//           duration: Duration(milliseconds: 500),
//           child: Container(
//             color: Colors.grey[100], // Light grey background for the entire screen
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 // Notification Settings Section
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(width * 0.05, height * 0.03, width * 0.05, height * 0.01),
//                   child: Text(
//                     'NOTIFICATION SETTINGS',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: height * 0.018,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: width * 0.04),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildSettingsOption(
//                         context: context,
//                         title: 'Receive Notification',
//                         value: isChecked1,
//                         onChanged: _onChangedReceiveNotification,
//                         isToggle: true,
//                         showDivider: true,
//                       ),
//                       _buildSettingsOption(
//                         context: context,
//                         title: 'Tone',
//                         subtitle: 'notification_001',
//                         onTap: () {
//                           AppSettings.openAppSettings();
//                         },
//                         showDivider: true,
//                       ),
//                       _buildSettingsOption(
//                         context: context,
//                         title: 'Vibrate',
//                         value: isChecked2,
//                         onChanged: _onChangedVibrate,
//                         isToggle: true,
//                         isEnabled: _isEnabled, // Control enabled state
//                         showDivider: false, // No divider after the last item in this group
//                       ),
//                       // Removed Blink LED as it was commented out in original logic
//                     ],
//                   ),
//                 ),
//
//                 // Delete Account Section
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(width * 0.05, height * 0.03, width * 0.05, height * 0.01),
//                   child: Text(
//                     'DELETE ACCOUNT',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: height * 0.018,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: width * 0.04),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildSettingsButton(
//                         context: context,
//                         title: 'Cancel Registration',
//                         onTap: () {
//                           // Handle cancel registration
//                           print('Cancel Registration tapped');
//                         },
//                         showDivider: true,
//                       ),
//                       _buildSettingsButton(
//                         context: context,
//                         title: 'Delete My Account Globally',
//                         subtitle: 'This will cancel your registration for any other events on the platform and permanently delete all your data.',
//                         onTap: () {
//                           // Handle delete account globally
//                           print('Delete My Account Globally tapped');
//                         },
//                         showDivider: false, // No divider after the last item
//                         isDestructive: true, // For destructive action styling
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _subscribe() async {
//     await FirebaseMessaging.instance.subscribeToTopic("Rec");
//   }
//
//   // New reusable widget for a setting option (with or without toggle)
//   Widget _buildSettingsOption({
//     required BuildContext context,
//     required String title,
//     String? subtitle,
//     bool isToggle = false,
//     bool value = false,
//     ValueChanged<bool?>? onChanged,
//     VoidCallback? onTap,
//     bool showDivider = false,
//     bool isEnabled = true, // To control switch/checkbox enabled state
//   }) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//
//     return Column(
//       children: [
//         InkWell(
//           onTap: isToggle ? null : onTap, // Only tap if not a toggle
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.015),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: height * 0.022,
//                           color: isEnabled ? Colors.black : Colors.grey, // Grey out if disabled
//                         ),
//                       ),
//                       if (subtitle != null)
//                         Text(
//                           subtitle,
//                           style: TextStyle(
//                             fontSize: height * 0.016,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 if (isToggle)
//                   Transform.scale(
//                     scale: 0.8, // Adjust scale to make switch smaller if needed
//                     child: CupertinoSwitch(
//                       value: value,
//                       onChanged: isEnabled ? onChanged : null, // Disable switch if isEnabled is false
//                       activeColor: Colors.teal, // Example active color
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         if (showDivider)
//           Divider(
//             color: Colors.grey[300],
//             height: 1,
//             indent: width * 0.04,
//             endIndent: width * 0.04,
//           ),
//       ],
//     );
//   }
//
//
//   // New reusable widget for a button-like setting item (e.g., Delete Account)
//   Widget _buildSettingsButton({
//     required BuildContext context,
//     required String title,
//     String? subtitle,
//     required VoidCallback onTap,
//     bool showDivider = false,
//     bool isDestructive = false, // For red text color
//   }) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//
//     return Column(
//       children: [
//         InkWell(
//           onTap: onTap,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.015),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: height * 0.022,
//                     color: isDestructive ? Colors.red : Colors.blue, // Blue for normal, red for destructive
//                   ),
//                 ),
//                 if (subtitle != null)
//                   Padding(
//                     padding: EdgeInsets.only(top: height * 0.005),
//                     child: Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: height * 0.016,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         if (showDivider)
//           Divider(
//             color: Colors.grey[300],
//             height: 1,
//             indent: width * 0.04,
//             endIndent: width * 0.04,
//           ),
//       ],
//     );
//   }
// }
//
// // Dummy WelcomPage to resolve any previous navigation errors
// class WelcomPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Welcome'),
//       ),
//       body: const Center(
//         child: Text('Welcome to the next page!'),
//       ),
//     );
//   }
// }*/
