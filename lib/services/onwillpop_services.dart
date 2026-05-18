import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnWillPop extends StatelessWidget {
  get onWillPop1 => null;
  @override
  Widget build(BuildContext context) {
     Future<bool> onWillPop1() async {
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
    return Scaffold();
  }
}
