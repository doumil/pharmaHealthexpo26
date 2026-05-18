import 'package:emecexpo/details/CongressFolder/BreakoutDay12.dart';
import 'package:emecexpo/tabs/FACEBOOK.dart';
import 'package:emecexpo/tabs/INSTAGRAM.dart';
import 'package:emecexpo/tabs/LINKEDIN.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Conggress_12.dart';
import 'CongressFolder/BreakoutDay13.dart';
import 'CongressFolder/MainDay12.dart';
import 'CongressFolder/MainDay13.dart';
import 'CongressFolder/BreakoutDay11.dart';


class DayEventBreakout extends StatefulWidget {
  const DayEventBreakout({Key? key}) : super(key: key);

  @override
  _DayEventBreakoutState createState() => _DayEventBreakoutState();
}

class _DayEventBreakoutState extends State<DayEventBreakout> {
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
                              child: Text("11 September vip"),
                            ),
                            Tab(
                              child: Text("12 September vip"),
                            ),
                            Tab(
                              child: Text("13 September vip"),
                            ),
                          ]
                      ),
                    ),
                    Expanded(
                      child:TabBarView(
                        children: [
                          Container(
                            child :BreakoutDay11Screen(),
                          ),
                          Container(
                            child: BreakoutDay12Screen(),
                          ),
                          Container(
                            child: BreakoutDay13Screen(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
