// lib/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:pharma_health_expo/model/notification_model.dart';
import 'package:pharma_health_expo/model/congress_model_detail.dart';

class DataBaseHelperNotif {
  final String notifTable = 'notificationtable';
  final String columnId = 'id';
  final String columnName = 'name';
  final String columnTitle = 'title';
  final String columnBody = 'body';
  final String columnDate = 'date';
  final String columnDtime = 'dtime';
  final String columnDiscription = 'discriptions';
  final String columnIsRead = 'isRead';

  final String agendaTable = "agendatable";
  final String columnAgendaTitle = 'title';
  final String columnDiscriptionAgenda = 'discription';
  final String columnDatetimeStart = 'datetimeStart';
  final String columnDatetimeEnd = 'datetimeEnd';

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'dbEmec3.db');

    var myOwnDB = await openDatabase(
      path,
      version: 4, // رفعنا النسخة بـ 1 باش يتم تحديث الجدول وإضافة الأعمدة الجديدة تلقائياً
      onCreate: (Database db, int newVersion) async {
        Batch batch = db.batch();

        var sql1 = "CREATE TABLE $notifTable ("
            "$columnId INTEGER PRIMARY KEY AUTOINCREMENT, "
            "$columnName TEXT, "
            "$columnTitle TEXT, "
            "$columnBody TEXT, "
            "$columnDate TEXT, "
            "$columnDtime TEXT, "
            "$columnDiscription TEXT, "
            "$columnIsRead INTEGER"
            ")";
        batch.execute(sql1);

        var sql2 = "CREATE TABLE $agendaTable ("
            "$columnId INTEGER PRIMARY KEY AUTOINCREMENT, "
            "$columnAgendaTitle TEXT, "
            "$columnDiscriptionAgenda TEXT, "
            "$columnDatetimeStart DATETIME, "
            "$columnDatetimeEnd DATETIME"
            ")";
        batch.execute(sql2);

        await batch.commit();
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // في حالة كان التطبيق مثبت من قبل ومحتاج يضيف أعمدة title و body و isRead بدون مسح بيانات القدامى
        if (oldVersion < 4) {
          try {
            await db.execute("ALTER TABLE $notifTable ADD COLUMN $columnTitle TEXT");
            await db.execute("ALTER TABLE $notifTable ADD COLUMN $columnBody TEXT");
            await db.execute("ALTER TABLE $notifTable ADD COLUMN $columnIsRead INTEGER");
          } catch (_) {}
        }
      },
    );
    return myOwnDB;
  }

  // Save notification
  Future<int> saveNoti(NotifClass Noti) async {
    var dbClient = await db;
    int result = await dbClient.insert(
      notifTable,
      Noti.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  // Save agenda
  Future<int> saveAgenda(CongressDClass Agenda) async {
    var dbClient = await db;
    int result = await dbClient.insert(agendaTable, Agenda.toMap());
    return result;
  }

  // Get list of notifications (مستغلاً NotifClass.fromMap مباشرة)
  Future<List<NotifClass>> getListNoti() async {
    final dbList = await db;
    final List<Map<String, dynamic>> maps = await dbList.query(notifTable);

    return List.generate(maps.length, (i) {
      return NotifClass.fromMap(maps[i]);
    });
  }

  // Get list of Agenda
  Future<List<CongressDClass>> getListAgenda() async {
    final dbList = await db;
    final List<Map<String, dynamic>> maps = await dbList.query(agendaTable);

    return List.generate(maps.length, (i) {
      return CongressDClass(
        maps[i]['title'],
        maps[i]['discription'],
        maps[i]['datetimeStart'],
        maps[i]['datetimeEnd'],
      );
    });
  }

  // Select all notification
  Future<List<Map<String, dynamic>>> getAllNoti() async {
    var dbClient = await db;
    return await dbClient.query(notifTable);
  }

  // Select all agenda
  Future<List<Map<String, dynamic>>> getAllAgenda() async {
    var dbClient = await db;
    return await dbClient.query(agendaTable);
  }
}