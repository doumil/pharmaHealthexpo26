// lib/app_user_guide_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:pharma_health_expo/providers/theme_provider.dart'; // Import ThemeProvider

class AppUserGuideScreen extends StatelessWidget {
  const AppUserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('App User Guide')),
        // ✅ Apply primaryColor from the theme
        backgroundColor: theme.primaryColor,
        // ✅ Apply whiteColor for the back button and title text
        foregroundColor: theme.whiteColor,
      ),
      body: Center(
        child: Text(
          'Content for App User Guide goes here.',
          // ✅ Apply blackColor from the theme
          style: TextStyle(color: theme.blackColor),
        ),
      ),
    );
  }
}