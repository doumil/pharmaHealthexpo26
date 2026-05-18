import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // Import ThemeProvider

import 'model/congress_model.dart';
import 'model/activities_model.dart';

class ActivitesScreen extends StatefulWidget {
  const ActivitesScreen({Key? key}) : super(key: key);

  @override
  _ActivitesScreenState createState() => _ActivitesScreenState();
}

class _ActivitesScreenState extends State<ActivitesScreen> {
  List<ActivitiesClass> litems = [];
  List<ActivitiesClass> litemsAllS = [];
  bool isLoading = true;

  @override
  void initState() {
    litems.clear();
    isLoading = true;
    _loadData();
    litemsAllS = litems;
    super.initState();
  }

  void _Search(String entrK) {
    List<ActivitiesClass> result = [];
    if (entrK.isNotEmpty) {
      result = litems
          .where((user) => user.discription
          .toString()
          .trim()
          .toUpperCase()
          .contains(entrK.toUpperCase()))
          .toList();
      setState(() {
        litems = result;
      });
      if (result.isEmpty) {
        Fluttertoast.showToast(
          msg: "Search not found...!",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } else {
      setState(() {
        litems = litemsAllS;
      });
    }
  }

  _loadData() async {
    // Data loading logic
    var act1 = ActivitiesClass(
        "DOCUWARE",
        "ipad's tombola ",
        "During the 3days show , we will be raffing "
            "and ipad 10 ... "
            "just have to visit us at booth C308"
            "and guess how mush wasted paper is inside the box."
            "\n\n Dont miss it !",
        "tue, 14 jun 09:00");
    litems.add(act1);
    var act2 = ActivitiesClass(
        "DOCUWARE",
        "ipad's tombola ",
        "During the 3days show , we will be raffing "
            "and ipad 10 ... "
            "just have to visit us at booth C308"
            "and guess how mush wasted paper is inside the box."
            "\n\n Dont miss it !",
        "tue, 14 jun 09:00");
    litems.add(act2);
    var act3 = ActivitiesClass(
        "DOCUWARE",
        "ipad's tombola ",
        "During the 3days show , we will be raffing "
            "and ipad 10 ... "
            "just have to visit us at booth C308"
            "and guess how mush wasted paper is inside the box."
            "\n\n Dont miss it !",
        "tue, 14 jun 09:00");
    litems.add(act3);
    var act4 = ActivitiesClass(
        "DOCUWARE",
        "ipad's tombola ",
        "During the 3days show , we will be raffing "
            "and ipad 10 ... "
            "just have to visit us at booth C308"
            "and guess how mush wasted paper is inside the box."
            "\n\n Dont miss it !",
        "tue, 14 jun 09:00");
    litems.add(act4);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

/*Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ?? false;
  }*/

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Container(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(''),
              // ✅ Apply primaryColor
              backgroundColor: theme.primaryColor,
              automaticallyImplyLeading: false,
              actions: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    // ✅ Apply secondaryColor
                    cursorColor: theme.secondaryColor,
                    // ✅ Apply whiteColor
                    style: TextStyle(color: theme.whiteColor),
                    onChanged: (value) => _Search(value),
                    obscureText: false,
                    decoration: InputDecoration(
                      // ✅ Apply whiteColor
                      hintText: "Search",
                      hintStyle: TextStyle(color: theme.whiteColor),
                      suffixIcon: Icon(
                        Icons.search,
                        // ✅ Apply whiteColor
                        color: theme.whiteColor,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          // ✅ Apply secondaryColor
                            color: theme.secondaryColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          // ✅ Apply secondaryColor
                            color: theme.secondaryColor,
                            width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: isLoading == true
                ? Center(
                child: SpinKitThreeBounce(
                  // ✅ Apply secondaryColor
                  color: theme.secondaryColor,
                  size: 30.0,
                ))
                : FadeInDown(
              duration: Duration(milliseconds: 500),
              child: Container(
                child: new ListView.builder(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: litems.length,
                    itemBuilder: (_, int position) {
                      return new Card(
                        margin: EdgeInsets.only(top: height * 0.01),
                        // ✅ Apply whiteColor
                        color: theme.whiteColor,
                        shape: BorderDirectional(
                          bottom:
                          BorderSide(color: Colors.black12, width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 20,
                              child: Container(
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/ICON-EMEC.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 80,
                              child: Container(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        // ✅ Apply primaryColor
                                        color: theme.primaryColor,
                                        borderRadius:
                                        BorderRadius.horizontal(
                                          left: Radius.circular(5.0),
                                          right: Radius.circular(5.0),
                                        ),
                                      ),
                                      width: double.maxFinite,
                                      child: Text(
                                        "  ${litems[position].datetime}",
                                        style: TextStyle(
                                          // ✅ Apply whiteColor
                                            color: theme.whiteColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                      EdgeInsets.fromLTRB(0, 4, 0, 0),
                                      child: Text(
                                          "${litems[position].shortname}\n",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.bold)),
                                    ),
                                    Container(
                                      child: Text(
                                          "${litems[position].discription}\n"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
          ),
        ));
  }
}