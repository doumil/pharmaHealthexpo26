// lib/social_m_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:pharma_health_expo/providers/theme_provider.dart'; // 💡 Import your ThemeProvider
import 'main.dart';
import 'model/app_theme_data.dart'; // 💡 Import your AppThemeData
import 'package:pharma_health_expo/tabs/FACEBOOK.dart';
import 'package:pharma_health_expo/tabs/INSTAGRAM.dart';
import 'package:pharma_health_expo/tabs/LINKEDIN.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SocialMScreen extends StatefulWidget {
  const SocialMScreen({Key? key}) : super(key: key);

  @override
  _SocialMScreenState createState() => _SocialMScreenState();
}

class _SocialMScreenState extends State<SocialMScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Êtes-vous sûr', style: TextStyle(color: theme.blackColor)),
        content: Text('Voulez-vous quitter une application', style: TextStyle(color: theme.blackColor)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Non', style: TextStyle(color: theme.primaryColor)),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text('Oui', style: TextStyle(color: theme.primaryColor)),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    late SharedPreferences prefs;
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: theme.whiteColor,
          appBar: AppBar(
            title: Text(
              "Social Media",
              style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Assuming a light icon on a colored AppBar
              onPressed: () async{
                prefs = await SharedPreferences.getInstance();
                prefs.setString("Data", "99");
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => WelcomPage()));
              },
            ),
            backgroundColor: theme.primaryColor,
            elevation: 0,
            centerTitle: true,
            actions: const <Widget>[],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                color: theme.primaryColor,
                child: TabBar(
                    unselectedLabelColor: theme.secondaryColor,
                    labelColor: theme.whiteColor,
                    indicatorColor: theme.whiteColor,
                    tabs: const [
                      Tab(
                        child: Text("INSTAGRAM"),
                      ),
                      Tab(
                        text:"FACEBOOK",
                      ),
                      Tab(
                        text:"LINKEDIN",
                      )
                    ]
                ),
              ),
            ),
          ),
          body: Container(
            color: theme.whiteColor,
            child: const TabBarView(children: [
              InstagramScreen(),
              FacebookScreen(),
              LINKEDINScreen(),
            ]),
          ),
        )
    );
  }
}