// import 'package:animate_do/animate_do.dart';
// import 'package:emecexpo/model/congress_model_detail.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../database_helper/database_helper.dart';
// import '../../main.dart';
// import '../../model/CreneauClass.dart';
// import '../../services/local_notification_service.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:add_2_calendar/add_2_calendar.dart';
// import 'package:emecexpo/model/notification_model.dart';
//
// class CreneauScreen extends StatefulWidget {
//   bool check;
//   CreneauScreen({required this.check});
//
//   @override
//   _CreneauScreenState createState() => _CreneauScreenState();
// }
//
// class _CreneauScreenState extends State<CreneauScreen> {
//   late SharedPreferences prefs;
//   List<CreneauClass> litems = [];
//   List<CreneauClass> litemsAllS = [];
//   bool isLoading = true;
//   // Function to update litems for Button 1
//   void loadItemsForButton1() {
//     setState(() {
//       litems.clear();
//       litems.add(CreneauClass("10:00", "12:00"));
//       litems.add(CreneauClass("12:00", "14:00"));
//       litems.add(CreneauClass("14:00", "16:00"));
//       litems.add(CreneauClass("16:00", "17:00"));
//       litems.add(CreneauClass("17:00", "19:30"));
//     });
//   }
//
//   // Function to update litems for Button 2
//   void loadItemsForButton2() {
//     setState(() {
//       litems.clear();
//       litems.add(CreneauClass("08:00", "10:00"));
//       litems.add(CreneauClass("09:00", "11:00"));
//       litems.add(CreneauClass("11:00", "13:00"));
//       litems.add(CreneauClass("13:00", "15:00"));
//       litems.add(CreneauClass("15:00", "17:00"));
//       litems.add(CreneauClass("17:00", "19:00"));
//       litems.add(CreneauClass("19:00", "21:00"));
//       litems.add(CreneauClass("21:00", "23:00"));
//       litems.add(CreneauClass("23:00", "01:00"));
//       litems.add(CreneauClass("01:00", "03:00"));
//
//
//     });
//   }
//   void initState() {
//     litems.clear();
//     isLoading = true;
//     _loadData();
//     litemsAllS=litems;
//     super.initState();
//   }
//   _loadData() async {
//     // var url = "http://192.168.8.100/emecexpo/loadDetailCongress.php";
//     //var res = await http.post(Uri.parse(url));
//     //List<ProductClass> prod = (json.decode(res.body) as List)
//     //  .map((data) => ProductClass.fromJson(data))
//     //.toList();
//     //litems=prod;
//     if (this.mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }
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
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("EMEC EXPO"),
//           backgroundColor: Color(0xff261350),
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back), // You can use any icon you prefer
//             onPressed: () async{
//               prefs = await SharedPreferences.getInstance();
//               prefs.setString("Data", "9");
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           WelcomPage()));
//             },
//           ),
//         ),
//         extendBodyBehindAppBar: true,
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 2,
//               child: Container(
//                 margin: EdgeInsets.only(top: 80), // Removed bottom margin
//                 width: double.infinity,
//                 child: Card(
//                   color: Colors.white,
//                   shape: BorderDirectional(
//                     bottom: BorderSide(color: Colors.black12, width: 1),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 8, bottom: 8), // Adjust padding to reduce bottom space
//                     child: ListTile(
//                       leading: ClipOval(
//                         child: Image.asset(
//                           'assets/Comercials/Comercials2024/1.jpeg',
//                           width: 60,
//                           height: 60,
//                         ),
//                       ),
//                       title: Padding(
//                         padding: EdgeInsets.only(bottom: 4), // Slight adjustment
//                         child: Text(
//                           "Hassan EL OUARDY",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       subtitle: Text(
//                         "Co-Founder of Shipsen",
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onTap: () {
//                         // Handle tap
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 4, // Acts as the spacer
//               child: Container(
//                 color: Colors.grey, // Your desired color for the spacer
//               ),
//             ),
//             Expanded(
//               flex: 0,
//               child: Container(
//                 //padding: EdgeInsets.fromLTRB(0, 0, 0,0),
//                 //margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                 decoration: BoxDecoration(
//                   color: Color(0xff261350),
//                 ),
//                 width: double.maxFinite,
//                 child: Row(
//                   children: [
//                     // Button 1
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent, // Ancien 'primary'
//                           shadowColor: Colors.transparent, // Ancien 'shadowColor'
//                           elevation: 0, // Ajouté pour enlever l'ombre
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.horizontal(
//                               left: Radius.circular(5.0),
//                               right: Radius.circular(5.0),
//                             ),
//                             side: BorderSide(
//                               color: Colors.transparent, // Couleur de la bordure
//                             ),
//                           ),
//                         ),
//                         onPressed: () {
//                           loadItemsForButton1(); // Action for Button 1
//                         },
//                         child: Text(
//                           "11-05-25",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                     // Button 2
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent, // Ancien 'primary'
//                           shadowColor: Colors.transparent,
//                           elevation: 0, // Utiliser elevation: 0 pour enlever l'ombre
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.horizontal(
//                               left: Radius.circular(5.0),
//                               right: Radius.circular(5.0),
//                             ),
//                             side: BorderSide(
//                               color: Colors.transparent, // Couleur de la bordure
//                             ),
//                           ),
//                         ),
//                         onPressed: () {
//                           loadItemsForButton2(); // Action for Button 2
//                         },
//                         child: Text(
//                           "12-05-25",
//                           style: TextStyle(
//                             color: Colors.white, // Couleur du texte
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ),
//             ),
//             Expanded(
//                 flex: 1,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: litems.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Padding(
//                       padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
//                       child: Center(
//                         child: Container(
//                           width: 100,
//                           //color: Colors.red,
//                           child: ListTile(
//                             leading:Container(
//                               padding: EdgeInsets.fromLTRB(4, 4,4,4),
//                               decoration: BoxDecoration(
//                                 color: Color(0xff261350),
//                                 borderRadius: BorderRadius.horizontal(
//                                   left: Radius.circular(5.0),
//                                   right: Radius.circular(5.0),
//                                 ),
//                               ),
//                               width:60.0,
//                               child: Center(child: Text("${litems[index].datetimeStart}\n${litems[index].datetimeEnd}",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),)),
//                             ),
//                             onTap: () {
//                               //if (widget.check == true) {
//                                 setState(() {
//                                   //widget.check = !widget.check;
//                                   // _addAgenda();
//                                   showDialog<String>(
//                                     context: context,
//                                     builder:
//                                         (BuildContext context) =>
//                                         Column(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                           children: [
//                                             //(check)
//                                             //? MyDialogDAgenda()
//                                             MyDialog()
//                                           ],
//                                         ),
//                                   );
//                                 });
//                               //}
//                             },
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 )),
//           ],
//         ));
//   }
// }
// class MyDialog extends StatefulWidget {
//   @override
//   _MyDialogState createState() => new _MyDialogState();
// }
//
// class _MyDialogState extends State<MyDialog> {
//   bool isChecked = false;
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//     return FadeInUp(
//       duration: Duration(milliseconds: 500),
//       child: AlertDialog(
//           title: Container(child: Text("confirmer votre creneau")),
//           content: Container(),
//           actions: <Widget>[
//             Container(
//                 height: height * 0.084,
//                 width: double.maxFinite,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
//                       decoration: BoxDecoration(
//                         color: Color(0xff261350),
//                         borderRadius: BorderRadius.horizontal(
//                           left: Radius.circular(5.0),
//                           right: Radius.circular(5.0),
//                         ),
//                       ),
//                       //width:30.0,
//                       child: Center(
//                           child: Text(
//                             "11-05-25",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold),
//                           )),
//                     ),
//                     const SizedBox(
//                       height: 4.0,
//                     ),
//                     Container(
//                       padding: EdgeInsets.fromLTRB(2, 4, 2, 4),
//                       decoration: BoxDecoration(
//                         color: Color(0xff261350),
//                         borderRadius: BorderRadius.horizontal(
//                           left: Radius.circular(5.0),
//                           right: Radius.circular(5.0),
//                         ),
//                       ),
//                       child: Center(
//                           child: Text(
//                             "10 : 00",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold),
//                           )),
//                     ),
//                   ],
//                 )),
//             Row(
//               children: [
//                 Container(
//                     child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           Container(
//                               padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
//                               child: Checkbox(
//                                 value: isChecked,
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     isChecked = value!;
//                                   });
//                                 },
//                               )),
//                           GestureDetector(
//                               onTap: () {
//                                 setState(() {});
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
//                                 child: Text('add to google calondar',
//                                     style: TextStyle(fontSize: height * 0.020)),
//                               )),
//                         ])),
//               ],
//             ),
//             Row(
//               children: [
//                 new TextButton(
//                   onPressed: () {
//                     // Navigator.pop(context, 'Annuler');
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CreneauScreen(
//                               check: false,
//                             )));
//                   },
//                   child: new Text('Cancel',
//                       style: TextStyle(
//                           color: Color(0xff00c1c1),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold)),
//                 ),
//                 new ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: const RoundedRectangleBorder(
//                         side: BorderSide(
//                           width: 2,
//                           color: Color(0xff261350),
//                         ),
//                         borderRadius: BorderRadius.all(Radius.circular(8.0))),
//                     //primary: Colors.white,
//                     backgroundColor: Colors.white,
//                   ),
//                   //color: Colors.white,
//                   onPressed: () {
//                     if (isChecked == true) {
//                       _addTogoogle();
//                     }
//                     _addAgenda();
//                     //Navigator.pop(context, 'Annuler');
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 CreneauScreen(check: false)));
//                     // check = true;
//                     // print(check);
//                   },
//                   child: Text(
//                     ('confirmer'),
//                     style: TextStyle(
//                         fontSize: 18,
//                         color: Color(0xff261350),
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ]),
//     );
//   }
//
//   Future<void> _addTogoogle() async {
//     NotificationService().showNotifByDate(
//         title: 'EMEC EXPO',
//         body: "Performing hot reload..."
//             "Syncing files to device CPH1819..."
//             "Reloaded 2 of 1626 libraries in 1 958ms (compile: 151 ms, reload: 711 ms, reassemble: 577 ms.",
//         date: DateTime.now().add(Duration(seconds: 10)));
//     final Event event = Event(
//       title: 'Event title',
//       description: 'Event description',
//       location: 'Event location',
//       startDate: DateTime.now(),
//       endDate: DateTime.now(),
//       androidParams: AndroidParams(
//         emailInvites: [], // on Android, you can add invite emails to your event.
//       ),
//     );
//     Add2Calendar.addEvent2Cal(event);
//   }
// }
//
// void _addAgenda() async {
//   String title='EMEC EXPO',body="Introducing an all-new Lottie Editor- a web-based editor "
//       "that allows you to edit, tweak and personalize your Lottie animations.";
//   var db = new DataBaseHelperNotif();
//   NotificationService().showNotifByDate(
//       title: title,
//       body: body,
//       date: DateTime.now().add(Duration(seconds: 10)));
//   //List<CongressDClass> LAgenda=[];
//   var c1 = CongressDClass(
//       title,
//       body,
//       "10:00",
//       "11:00");
//   //LAgenda.add(c1);
//   await db.saveAgenda(c1);
//   await db.saveNoti(NotifClass(title,"03/03/2025","10:00", body));
//   Fluttertoast.showToast(
//     msg: "succès",
//     toastLength: Toast.LENGTH_SHORT,
//   );
// }
//
// class MyDialogDAgenda extends StatefulWidget {
//   bool check;
//   MyDialogDAgenda({required this.check});
//   @override
//   _MyDialogDAgendaState createState() => new _MyDialogDAgendaState();
// }
//
// class _MyDialogDAgendaState extends State<MyDialogDAgenda> {
//   bool isChecked = false;
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//     return FadeInUp(
//       duration: Duration(milliseconds: 500),
//       child: AlertDialog(
//           title:
//           Container(child: Text("Are you sure to remove youre agenda ?")),
//           content: Container(),
//           actions: <Widget>[
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 new TextButton(
//                   onPressed: () {
//                     //Navigator.pop(context, 'Annuler');
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CreneauScreen(
//                               check: false,
//                             )));
//                     //check = false;
//                     //print(check);
//                   },
//                   child: new Text('Cancel',
//                       style: TextStyle(
//                           color: Color(0xff00c1c1),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold)),
//                 ),
//                 new ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: const RoundedRectangleBorder(
//                         side: BorderSide(
//                           width: 2,
//                           color: Color(0xff261350),
//                         ),
//                         borderRadius: BorderRadius.all(Radius.circular(8.0))),
//                     //primary: Colors.white,
//                     backgroundColor: Colors.white, // Replaces 'primary'
//                   ),
//                   //color: Colors.white,
//                   onPressed: () {
//                     //check = true;
//                     //print(check);
//                     Navigator.pop(context, 'Annuler');
//                   },
//                   child: Text(
//                     ('yes'),
//                     style: TextStyle(
//                         fontSize: 20,
//                         color: Color(0xff261350),
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ]),
//     );
//   }
// }
//
