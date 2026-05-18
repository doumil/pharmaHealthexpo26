// lib/scheldule_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart'; // Make sure this is the correct path
import 'model/app_theme_data.dart'; // This is needed to access your theme colors

class SchelduleScreen extends StatefulWidget {
  const SchelduleScreen ({Key? key}) : super(key: key);

  @override
  _SchelduleScreenState createState() => _SchelduleScreenState();
}

class _SchelduleScreenState extends State<SchelduleScreen> {
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Êtes-vous sûr', style: TextStyle(color: Colors.black)),
        content: new Text('Voulez-vous quitter une application', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Non', style: TextStyle(color: Color(0xff261350))),
          ),
          new TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: new Text('Oui', style: TextStyle(color: Color(0xff261350))),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return
      //WillPopScope(
      //onWillPop: _onWillPop,
      //child:
    Scaffold(
        backgroundColor:Colors.white,
        extendBodyBehindAppBar: true,
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Exhibitors Area Opening hours :\n(Business Pass, Premium VIP, Pass, Honour Pass holders)", theme),
                _buildTimeSection(width, height, theme),
                _buildSectionTitle("Exibitors", theme),
                _buildTimeSection(width, height, theme),
                _buildSectionTitle("Speakers", theme),
                _buildTimeSection(width, height, theme),
                _buildSectionTitle("Press Pass", theme),
                _buildTimeSection(width, height, theme),
              ],
            ),
          ),
        ),
      //),
    );
  }

  Widget _buildSectionTitle(String title, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(5.0),
          right: Radius.circular(5.0),
        ),
      ),
      width: double.maxFinite,
      child: Text(
        title,
        style: TextStyle(color: theme.whiteColor, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTimeSection(double width, double height, AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(width * 0.04, width * 0.04, width * 0.04, width * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTimeRow("Mercredi 10 Mai - 9h à 19h", width, height, theme),
          _buildTimeRow("Jeudi 11 Mai - 9h à 19h", width, height, theme),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String time, double width, double height, AppThemeData theme) {
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
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Text(
                time,
                style: TextStyle(
                  fontSize: height * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}