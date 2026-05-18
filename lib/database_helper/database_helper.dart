import 'dart:async';
import 'dart:io';
import 'package:emecexpo/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:emecexpo/model/notification_model.dart';
import 'package:emecexpo/model/congress_model_detail.dart';

class DataBaseHelperNotif{
  final String notifTable = 'notificationtable';
  final String columnId='id';
  final String columnName= 'name';
  final String columnDate = 'date';
  final String columnDtime='dtime';
  final String columnDiscription = 'discriptions';
  final String agendaTable="agendatable";
  final String columnTitle='title';
  final String columnDiscriptionAgenda='discription';
  final String columnDatetimeStart='datetimeStart';
  final String columnDatetimeEnd='datetimeEnd';
  Future<Database> get db async{
    var _db = await intDB();
    return _db;
  }
  intDB() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path , 'dbEmec3.db');
    var myOwnDB = await openDatabase(path,version: 3,
        onCreate:(Database db , int newVersion) async{
          Batch batch= db.batch();
          var sql1 = "CREATE TABLE $notifTable ("
              "$columnId INTEGER  auto_increment,"
              " $columnName TEXT, "
              "$columnDate TEXT,"
              "$columnDtime TEXT,"
              " $columnDiscription TEXT"
              ")";
          db.execute(sql1);
          var sql2 = "CREATE TABLE $agendaTable ("
              "$columnId INTEGER  auto_increment,"
              "$columnTitle TEXT,"
              " $columnDiscriptionAgenda TEXT, "
              "$columnDatetimeStart DATETIME,"
              "$columnDatetimeEnd DATETIME"
              ")";
          db.execute(sql2);
          await  batch.commit();
        });
    return myOwnDB;
  }
  //save notification
  Future<int> saveNoti( NotifClass Noti) async{
    var dbClient = await  db;
    int result = await dbClient.insert("$notifTable", Noti.toMap());
    return result;
  }
  //save agenda
  Future<int> saveAgenda( CongressDClass Agenda) async{
    var dbClient = await  db;
    int result = await dbClient.insert("$agendaTable", Agenda.toMap());
    return result;
  }
  //map by order

  //get list of notifications
  Future<List<NotifClass>> getListNoti() async {
    final dbList = await db;
    final List<Map<String, dynamic>> maps = await dbList.query("$notifTable");
    return List.generate(maps.length, (i) {
      return NotifClass(maps[i]['name'],maps[i]['date'],maps[i]['dtime'],maps[i]['discriptions']);
    });
  }
  //get list of Agenda
  Future<List<CongressDClass>> getListAgenda() async {
    final dbList = await db;
    final List<Map<String, dynamic>> maps = await dbList.query("$agendaTable");
    return List.generate(maps.length, (i) {
      return CongressDClass(maps[i]['title'],maps[i]['discription'],maps[i]['datetimeStart'],maps[i]['datetimeEnd']);
    });
  }
  // select all notification
  Future<List> getAllNoti() async{
    var dbClient = await  db;
    var sql = "SELECT * FROM $notifTable";
    List result = await dbClient.rawQuery(sql);
    return result.toList();
  }
  // select all agenda
  Future<List> getAllAgenda() async{
    var dbClient = await  db;
    var sql = "SELECT * FROM $agendaTable";
    List result = await dbClient.rawQuery(sql);
    return result.toList();
  }
}