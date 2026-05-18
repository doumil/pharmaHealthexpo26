// lib/information_screen.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart';

import 'model/app_theme_data.dart'; // 💡 Import your ThemeProvider

class InformationScreen extends StatefulWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        // ✅ Use whiteColor from theme for scaffold background
        backgroundColor: theme.whiteColor,
        extendBodyBehindAppBar: true,
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title 1
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                  decoration: BoxDecoration(
                    // ✅ Use primaryColor from theme
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5.0),
                      right: Radius.circular(5.0),
                    ),
                  ),
                  width: double.maxFinite,
                  child: Text(
                    "Exhibitors Area Opening hours :\n(Business Pass, Premium VIP, Pass, Honour Pass holders)",
                    style: TextStyle(
                      // ✅ Use whiteColor for text
                      color: theme.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Times for Title 1
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      width * 0.04, width * 0.04, width * 0.04, width * 0.01),
                  child: Column(
                    children: <Widget>[
                      _buildTimeRow(
                          context, "Mercredi 10 Mai - 9h à 19h", theme),
                      _buildTimeRow(
                          context, "Jeudi 11 Mai - 9h à 19h", theme),
                    ],
                  ),
                ),
                // Title 2
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 2, 2, 2),
                  decoration: BoxDecoration(
                    // ✅ Use primaryColor from theme
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5.0),
                      right: Radius.circular(5.0),
                    ),
                  ),
                  width: double.maxFinite,
                  child: Text(
                    "Exhibitors",
                    style: TextStyle(
                      // ✅ Use whiteColor for text
                      color: theme.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Times for Title 2
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      width * 0.04, width * 0.04, width * 0.04, width * 0.01),
                  child: Column(
                    children: <Widget>[
                      _buildTimeRow(
                          context, "Mercredi 10 Mai - 9h à 19h", theme),
                      _buildTimeRow(
                          context, "Jeudi 11 Mai - 9h à 19h", theme),
                    ],
                  ),
                ),
                // Title 3
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 2, 2, 2),
                  decoration: BoxDecoration(
                    // ✅ Use primaryColor from theme
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5.0),
                      right: Radius.circular(5.0),
                    ),
                  ),
                  width: double.maxFinite,
                  child: Text(
                    "Speakers",
                    style: TextStyle(
                      // ✅ Use whiteColor for text
                      color: theme.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Times for Title 3
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      width * 0.04, width * 0.04, width * 0.04, width * 0.01),
                  child: Column(
                    children: <Widget>[
                      _buildTimeRow(
                          context, "Mercredi 10 Mai - 9h à 19h", theme),
                      _buildTimeRow(
                          context, "Jeudi 11 Mai - 9h à 19h", theme),
                    ],
                  ),
                ),
                // Title 4
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 2, 2, 2),
                  decoration: BoxDecoration(
                    // ✅ Use primaryColor from theme
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5.0),
                      right: Radius.circular(5.0),
                    ),
                  ),
                  width: double.maxFinite,
                  child: Text(
                    "Press Pass",
                    style: TextStyle(
                      // ✅ Use whiteColor for text
                      color: theme.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Times for Title 4
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      width * 0.04, width * 0.04, width * 0.04, width * 0.01),
                  child: Column(
                    children: <Widget>[
                      _buildTimeRow(
                          context, "Mercredi 10 Mai - 9h à 19h", theme),
                      _buildTimeRow(
                          context, "Jeudi 11 Mai - 9h à 19h", theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    //  ),
    );
  }

  // Helper method to build a consistent row
  Widget _buildTimeRow(
      BuildContext context, String text, AppThemeData theme) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.03,
      margin: EdgeInsets.only(bottom: height * 0.01),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 5),
            child: Icon(
              Icons.access_time,
              size: height * 0.036,
              // ✅ Use blackColor with opacity for a subdued look
              color: theme.blackColor.withOpacity(0.5),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: height * 0.022,
                fontWeight: FontWeight.bold,
                // ✅ Use blackColor for the text
                color: theme.blackColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}