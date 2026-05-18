// lib/meeting_ratings_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Import the Provider package
import 'package:pharma_health_expo/providers/theme_provider.dart';

import 'main.dart'; // 💡 Import your ThemeProvider

class MeetingRatingsScreen extends StatelessWidget {
  const MeetingRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    late SharedPreferences prefs;
    // 💡 Access the theme provider and get the current theme data.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      // ✅ Use a color from the theme for the Scaffold background
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        title: Center(child: const Text('Meeting Ratings')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Assuming a light icon on a colored AppBar
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => WelcomPage()));
          },
        ),
        // ✅ Use the primary color from the theme for the AppBar background
        backgroundColor: theme.primaryColor,
        // ✅ Use the white color from the theme for the foreground icons and text
        foregroundColor: theme.whiteColor,
      ),
      body: Center(
        child: Text(
          'Content for Meeting Ratings goes here.',
          // ✅ Use a black color from the theme for the text
          style: TextStyle(color: theme.blackColor),
        ),
      ),
    );
  }
}