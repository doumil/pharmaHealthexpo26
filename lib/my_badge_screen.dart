// lib/my_badge_screen.dart (Final working version for display)
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // Import ThemeProvider
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/model/app_theme_data.dart';

import 'main.dart'; // Assuming this defines your theme structure

class MyBadgeScreen extends StatefulWidget {
  final User user;

  const MyBadgeScreen({super.key, required this.user});

  @override
  State<MyBadgeScreen> createState() => _MyBadgeScreenState();
}

class _MyBadgeScreenState extends State<MyBadgeScreen> {
  String? _qrCodeXml;

  @override
  void initState() {
    super.initState();
    _loadQrCode();
  }

  Future<void> _loadQrCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? xml = prefs.getString('qrCodeXml');
    setState(() {
      _qrCodeXml = xml;
    });
  }

  @override
  Widget build(BuildContext context) {
    late SharedPreferences prefs;
    // Access the current theme data
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      // 🎨 Apply theme background color
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        // 🎨 Apply theme primary color or surface color to AppBar
        backgroundColor: theme.primaryColor,
        // 🎨 Apply theme color to the title text
        title: Center(
          child: Text(
            "My Badge",
            style: TextStyle(color: theme.whiteColor),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), // Assuming a light icon on a colored AppBar
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => WelcomPage()));
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Display User Name
              Text(
                "${widget.user.prenom ?? ''} ${widget.user.nom ?? ''}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // 🎨 Apply theme primary text color
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              // 2. Display Company
              Text(
                "${widget.user.societe ?? 'N/A'}",
                style: TextStyle(
                  fontSize: 18,
                  // 🎨 Apply theme secondary text color
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // 3. Display QR Code (SVG from XML)
              if (_qrCodeXml != null && _qrCodeXml!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // 🎨 Use whiteColor for the QR code background (essential for scanning)
                    color: theme.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      // 🎨 Use theme black color for shadow
                      BoxShadow(blurRadius: 5, color: theme.blackColor.withOpacity(0.12))
                    ],
                  ),
                  child: SvgPicture.string(
                    _qrCodeXml!,
                    width: 250,
                    height: 250,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "QR Code loading or not available. Please ensure verification was successful.",
                    // 🎨 Apply theme primary text color
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),

              const SizedBox(height: 40),
              Text(
                "Scan this badge to network!",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  // 🎨 Apply theme secondary text color
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}