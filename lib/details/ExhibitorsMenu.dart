// lib/exhibitors_menu.dart or similar file

import 'package:emecexpo/Activities.dart';
import 'package:emecexpo/Exhibitors.dart'; // Make sure this imports your ExhibitorsScreen class
import 'package:emecexpo/News.dart';
import 'package:emecexpo/product.dart';
import 'package:emecexpo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../my_drawer_header.dart';

// 💡 Imports for dynamic theming (ensuring they remain)
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
// Ensure AppThemeData is available

class ExhibitorDScreen extends StatefulWidget {
  const ExhibitorDScreen({Key? key}) : super(key: key);

  @override
  _ExhibitorDScreenState createState() => _ExhibitorDScreenState();
}

class _ExhibitorDScreenState extends State<ExhibitorDScreen> {
  @override // 💡 Added @override for best practice
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    // 💡 Access theme for AlertDialog colors
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog( // 💡 Changed to non-new for modern Dart
        title: Text('Êtes-vous sûr', style: TextStyle(color: theme.blackColor)), // 💡 Dynamic color
        content: Text('Voulez-vous quitter une application', style: TextStyle(color: theme.blackColor)), // 💡 Dynamic color
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Non', style: TextStyle(color: theme.primaryColor)), // 💡 Dynamic color
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text('Oui ', style: TextStyle(color: theme.primaryColor)), // 💡 Dynamic color
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        appBar: AppBar(
          title: Text("EMEC EXPO"),
          backgroundColor: theme.primaryColor, // 💡 Dynamic color
          elevation: 0,
        ),
        body: DefaultTabController(
            length: 4,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              body: Column( // Container is unnecessary here
                children: [
                  Container(
                    color: theme.primaryColor, // 💡 Dynamic color for TabBar background
                    child: TabBar(
                        unselectedLabelColor: theme.secondaryColor, // 💡 Dynamic color
                        labelColor: theme.whiteColor, // 💡 Dynamic color
                        tabs:[
                          Tab(
                            text:"Exhibitor",
                          ),
                          Tab(
                            text:"Product",
                          ),
                          Tab(
                            text:"Activities",
                          ),
                          Tab(
                            text:"News",
                          ),
                        ]
                    ),

                  ),
                  Expanded(
                    child:TabBarView(children: [
                      // CORRECTED: Display the ExhibitorsScreen (your list of exhibitors) here
                      Container(
                        color: theme.whiteColor, // Set background color for content area
                        child :ExhibitorsScreen(),
                      ),
                      Container(
                        color: theme.whiteColor,
                        child: ProductScreen(),
                      ),
                      Container(
                        color: theme.whiteColor,
                        child: ActivitesScreen(),
                      ),
                      Container(
                        color: theme.whiteColor,
                        child: NewsScreen(),
                      ),
                    ],
                    ),
                  ),
                ],
              ),
            )),
     // ),
    );
  }
}