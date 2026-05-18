// import 'package:emecexpo/tabs/FACEBOOK.dart';
// import 'package:emecexpo/tabs/INSTAGRAM.dart';
// import 'package:emecexpo/tabs/LINKEDIN.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'Conggress_12.dart';
// import 'Congress_11.dart';
// import 'DayEventBreakout.dart';
// import 'DayEventMain.dart';
// import 'day1Creneau.dart';
// import 'day2Creneau.dart';
//
// class DetailCreneauscreen extends StatefulWidget {
//   const DetailCreneauscreen({Key? key}) : super(key: key);
//
//   @override
//   _DetailCreneauscreenState createState() => _DetailCreneauscreenState();
// }
//
// class _DetailCreneauscreenState extends State<DetailCreneauscreen> {
//   void initState() {
//     super.initState();
//   }
//
//   Future<bool> _onWillPop() async {
//     return (await showDialog(
//       context: context,
//       builder: (context) => new AlertDialog(
//         title: new Text('Êtes-vous sûr'),
//         content: new Text('Voulez-vous quitter une application'),
//         actions: <Widget>[
//           new TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: new Text('Non'),
//           ),
//           new TextButton(
//             onPressed: () => SystemNavigator.pop(),
//             child: new Text('Oui '),
//           ),
//         ],
//       ),
//     )) ??
//         false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: DefaultTabController(
//             length: 3,
//             child: Scaffold(
//               extendBodyBehindAppBar: true,
//               appBar: AppBar(
//                 title: Text("EMEC EXPO"),
//                 backgroundColor: Color(0xff261350),
//                 elevation: 0,
//                 leading: IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 bottom: PreferredSize(
//                   preferredSize: Size.fromHeight(kToolbarHeight), // TabBar height
//                   child: TabBar(
//                     unselectedLabelColor: const Color(0xff00c1c1),
//                     labelColor: Colors.white,
//                     tabs: [
//                       Tab(
//                         child: Text("Day 1"),
//                       ),
//                       Tab(
//                         child: Text("Day 2"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//                 body: Container(
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child:TabBarView(
//                         children: [
//                           Container(
//                             child :Day1Creneau(),
//                           ),
//                           Container(
//                             child: Day2Creneau(),
//                           ),
//                           // Container(
//                           //   child: DayEventMenu(),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )));
//   }
// }
