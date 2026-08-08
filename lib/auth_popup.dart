// lib/auth_popup.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_health_expo/login_screen.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';

class AuthPopup {
  static void show(BuildContext context) {
    // 🎨 جلب الـ Theme الحالي عبر Provider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.currentTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.blackColor, // لون خلفية الـ Dialog بناءً على الثيم
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.whiteColor.withOpacity(0.2)),
          ),
          title: Text(
            "Authentication Required",
            style: TextStyle(
              color: theme.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            "You need to log in or register to access this feature, view your badge, and connect with other attendees.",
            style: TextStyle(
              color: theme.whiteColor.withOpacity(0.8),
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.whiteColor.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondaryColor, // اللون الثانوي ديال الثيم
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text(
                "Log In / Register",
                style: TextStyle(
                  color: theme.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}