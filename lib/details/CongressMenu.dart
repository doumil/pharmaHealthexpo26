import 'package:emecexpo/tabs/FACEBOOK.dart';
import 'package:emecexpo/tabs/INSTAGRAM.dart';
import 'package:emecexpo/tabs/LINKEDIN.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Conggress_12.dart';
import 'Congress_11.dart';
import 'DayEventBreakout.dart';
import 'DayEventMain.dart';

class CongressMenu extends StatefulWidget {
  const CongressMenu({Key? key}) : super(key: key);

  @override
  _CongressMenuState createState() => _CongressMenuState();
}

class _CongressMenuState extends State<CongressMenu> {
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Êtes-vous sûr'),
        content: new Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Non'),
          ),
          new TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: new Text('Oui '),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
            length: 3,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              body: Container(
                child: Column(
                  children: [
                    Container(
                      color: Color(0xff261350),
                      child: TabBar(
                          unselectedLabelColor: const Color(0xff00c1c1),
                          labelColor:Colors.white,
                          tabs:[
                            Tab(
                              child: Text("MAIN STAGE (PAID)"),
                            ),
                            Tab(
                              child:Text("BREAKOUT STAGE (FREE)"),
                            ),
                            // Tab(
                            //   child:Text("Networking Area"),
                            // ),
                          ]
                      ),

                    ),
                    Expanded(
                      child:TabBarView(
                        children: [
                          Container(
                            child :DayEventMain(),
                          ),
                          Container(
                            child: DayEventBreakout(),
                          ),
                          // Container(
                          //   child: DayEventMenu(),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
