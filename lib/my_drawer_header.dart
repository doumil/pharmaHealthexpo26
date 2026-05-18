// lib/my_header_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/model/app_theme_data.dart'; // Import AppThemeData to use theme structure

class MyHeaderDrawer extends StatefulWidget {
  final User? user;
  // Callback function to execute the actual logout logic (e.g., clearing tokens and navigating to LoginScreen)
  final VoidCallback onLogout;

  const MyHeaderDrawer({Key? key, this.user, required this.onLogout}) : super(key: key);

  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {

  // Function to show the confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context, AppThemeData theme) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out of your account?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog first
                // EXECUTE THE LOGOUT CALLBACK PASSED FROM THE PARENT WIDGET
                widget.onLogout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final User? currentUser = widget.user;

    return Container(
      color: theme.primaryColor,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.28,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Logo ---
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: double.maxFinite,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/logo15.png",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),

          // --- User Info and Logout Icon (Centered Single Line) ---
          if (currentUser != null)
          // Start of Commented Code: Hiding Logout Icon and restructuring user info
          /*
            Row(
              // 1. Center the Row content (name + icon) horizontally
              mainAxisAlignment: MainAxisAlignment.center,
              // 2. Align them vertically in the center
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text widget for the user's name
                Text(
                  currentUser.name ?? '${currentUser.prenom ?? ''} ${currentUser.nom ?? ''}'.trim(),
                  style: TextStyle(
                    color: theme.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  // Removed explicit textAlign to let the Row handle centering visually
                  overflow: TextOverflow.ellipsis,
                ),

                // Add a small spacer between the text and icon
                const SizedBox(width: 8),

                // LOGOUT ICON (HIDDEN)
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: theme.whiteColor,
                    size: 24,
                  ),
                  onPressed: () {
                    _showLogoutConfirmationDialog(context, theme);
                  },
                  tooltip: 'Logout',
                ),
              ],
            )
            */
          // End of Commented Code

          // Display User Name Only (Centered)
            Text(
              currentUser.name ?? '${currentUser.prenom ?? ''} ${currentUser.nom ?? ''}'.trim(),
              style: TextStyle(
                color: theme.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Ensure centering
              overflow: TextOverflow.ellipsis,
            )
          else
            Column( // Guest User Column (remains centered)
              children: [
                Text(
                  "Welcome, Guest!",
                  style: TextStyle(
                    color: theme.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Please log in",
                  style: TextStyle(
                    color: theme.whiteColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}