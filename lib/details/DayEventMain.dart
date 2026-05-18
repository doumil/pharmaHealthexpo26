import 'package:emecexpo/tabs/FACEBOOK.dart';
import 'package:emecexpo/tabs/INSTAGRAM.dart';
import 'package:emecexpo/tabs/LINKEDIN.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Conggress_12.dart';
import 'CongressFolder/MainDay11.dart';
import 'CongressFolder/MainDay12.dart';
import 'CongressFolder/MainDay13.dart';
import 'Congress_11.dart';

class DayEventMain extends StatefulWidget {
  const DayEventMain({Key? key}) : super(key: key);

  @override
  _DayEventMainState createState() => _DayEventMainState();
}

class _DayEventMainState extends State<DayEventMain> {
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
                              child: Text("11 September"),
                            ),
                            Tab(
                              child: Text("12 September"),
                            ),
                            Tab(
                              child: Text("13 September"),
                            ),
                          ]
                      ),
                    ),
                    Expanded(
                      child:TabBarView(
                        children: [
                          Container(
                            //child :MainDay11Screen(),
                          ),
                          Container(
                            child: MainDay12Screen(),
                          ),
                          Container(
                            child: MainDay13Screen(),
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
