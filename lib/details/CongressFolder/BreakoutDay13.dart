import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../model/congress_model_detail.dart';
class BreakoutDay13Screen extends StatefulWidget {
  const BreakoutDay13Screen({Key? key}) : super(key: key);

  @override
  _BreakoutDay13ScreenState createState() => _BreakoutDay13ScreenState();
}

class _BreakoutDay13ScreenState extends State<BreakoutDay13Screen> {
  List<CongressDClass> litems = [];
  List<CongressDClass> litemsAllS = [];
  bool isLoading = true;
  void initState() {
    litems.clear();
    isLoading = true;
    _loadData();
    litemsAllS=litems;
    super.initState();
  }
  _loadData() async {
    // var url = "http://192.168.8.100/emecexpo/loadDetailCongress.php";
    //var res = await http.post(Uri.parse(url));
    //List<ProductClass> prod = (json.decode(res.body) as List)
    //  .map((data) => ProductClass.fromJson(data))
    //.toList();
    //litems=prod;
    var prod1=CongressDClass("vip lounge 11 september","Adaptive Soc Services","10:00","12:00");
    litems.add(prod1);
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: isLoading == true
            ? Center(
            child: SpinKitThreeBounce(
              color: Color(0xff00c1c1),
              size: 30.0,
            ))
            :  Container(
          child: Container(
            color: Colors.white,
            child: new ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: litems.length,
                itemBuilder: (_, int position) {
                  return new Card(
                    color: Colors.white,
                    shape: BorderDirectional(
                      bottom:BorderSide(color: Colors.black12, width: 1),
                    ),
                    child: new ListTile(
                      leading: Container(
                        padding: EdgeInsets.fromLTRB(4, 4,4,4),
                        decoration: BoxDecoration(
                          color: Color(0xff261350),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(5.0),
                            right: Radius.circular(5.0),
                          ),
                        ),
                        width:60.0,
                        child: Text("${litems[position].datetimeStart}\n${litems[position].datetimeEnd}",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                      ),
                      title: Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "${litems[position].title}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle:Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "${litems[position].discription}",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => DetailCongressScreen(check: false,)));
                      },
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
