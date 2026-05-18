// import 'dart:convert';
// import 'package:animate_do/animate_do.dart';
// import 'package:emecexpo/details/reserverCreneau/creneau.dart';
// import 'package:emecexpo/main.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../networking.dart';
// import 'Detailcreneau.dart';
// import 'package:http/http.dart' as http;
//
//
// import '../model/commercials.dart';
// import 'Detailcreneau.dart';
//
//
// class DetailNetworkinScreen extends StatefulWidget {
//   const DetailNetworkinScreen({Key? key}) : super(key: key);
//
//   @override
//   _DetailNetworkinScreenState createState() => _DetailNetworkinScreenState();
// }
//
// class _DetailNetworkinScreenState extends State<DetailNetworkinScreen> {
//   late SharedPreferences prefs;
//   List<Comercials> litems = [];
//   bool isLoading = true;
//   void initState() {
//     litems.clear();
//     isLoading = true;
//     _loadData();
//     super.initState();
//   }
//   _loadData() async {
//     //var url = "http://192.168.8.100/emecexpo/loadComercials.php";
//     //var res = await http.post(Uri.parse(url));
//     //List<Comercials> speaker = (json.decode(res.body) as List)
//     //  .map((data) => Comercials.fromJson(data))
//     // .toList();
//     var sp1=Comercials("Hassan", "EL OUARDY", "", "Co-Founder of Shipsen",
//         "assets/Comercials/Comercials2024/1.jpeg");
//     litems.add(sp1);
//     var sp2=Comercials("Reda", "AOUNI", "",
//         "Co-Founder of Shipsen",
//         "assets/Comercials/Comercials2024/2.png");
//     litems.add(sp2);
//     var sp3=Comercials("Abderrahmane ", "HASSANI IDRISSI", "", "CEO Shopyan, Directeur de Projet & Programme Neoxecutive",
//         "assets/Comercials/Comercials2024/3.png");
//     litems.add(sp3);
//     var sp4=Comercials("Yassine", "ZAIM", "", "Ingenieur informatique , Paiement en ligne Expert E-commerce",
//         "assets/Comercials/Comercials2024/4.png");
//     litems.add(sp4);
//     if (this.mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
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
//     return WillPopScope(
//         onWillPop: _onWillPop,
//         child: Scaffold(
//           extendBodyBehindAppBar: true,
//           appBar: AppBar(
//             title: Text("EMEC EXPO"),
//             backgroundColor: Color(0xff261350),
//             elevation: 0,
//             leading: IconButton(
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
//             ),
//           ),
//           body: isLoading == true
//               ? Center(
//               child: SpinKitThreeBounce(
//                 color: Color(0xff00c1c1),
//                 size: 30.0,
//               ))
//               :  FadeInDown(
//             duration: Duration(milliseconds: 500),
//             child: Container(
//               color:Colors.black26,
//               child: new ListView.builder(
//                   itemCount: litems.length,
//                   itemBuilder: (_, int position) {
//                     return new Card(
//                       margin: EdgeInsets.only(top: height * 0.01),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.horizontal(
//                             left: Radius.circular(5.0),
//                             right: Radius.circular(5.0),
//                           )
//                       ),
//                       child: new ListTile(
//                         leading:  ClipOval(
//                             child: Image.asset(
//                               width:60,
//                               height: 60,
//                               '${litems[position].image}',
//                             )),
//                         title:Container(
//                           child: Padding(
//                             padding: EdgeInsets.only(bottom: 2.0,left: 2,top: 2),
//                             child: Text("${litems[position].fname} ${litems[position].lname}",
//                               style: TextStyle( fontSize: 15,fontWeight:FontWeight.bold,color:  Color(0xff261350)),
//                               overflow:TextOverflow.visible,
//                             ),
//                           ),
//                         ),
//                         subtitle: Container(
//                           child: new Text("${litems[position].characteristic}",
//                             style: TextStyle(height: 2),
//                             overflow:TextOverflow.visible,
//                           ),
//                         ),
//                         onTap: (){
//                                                Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => CreneauScreen(check: true)));
//                         },
//                       ),
//                       elevation: 3.0,
//                     );
//                   }),
//             ),
//           ),
//         ));
//   }
// }
