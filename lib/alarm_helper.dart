import 'package:repeat_notifications/models/alarm_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final String tableAlarm = 'alarm';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnDateTime = 'minutesRepeat';
final String columnStatus = 'status';
final String columnColorIndex = 'gradientColorIndex';

class AlarmHelper {
  static Database? _database;
  static AlarmHelper? _alarmHelper;

  AlarmHelper._createInstance();
  factory AlarmHelper() => _alarmHelper ??= new AlarmHelper._createInstance();

  Future<Database> get database async =>
      _database ??= await initializeDatabase();

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnDateTime integer not null,
          $columnStatus integer,
          $columnColorIndex integer)
        ''');
      },
    );

    return database;
  }

  Future<int> insertAlarm(AlarmInfo alarmInfo) async {
    var db = await this.database;
    var result = await db.insert(tableAlarm, alarmInfo.toMap());
    print('resultID : $result');
    return result;
  }

  Future<AlarmInfo> getOneAlarm(int id) async {
    var db = await this.database;
    var result =
        await db.query(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
    return AlarmInfo.fromMap(result[0]);
  }

  Future<List<AlarmInfo>> getAlarms() async {
    List<AlarmInfo> _alarms = [];

    var db = await this.database;
    var result = await db.query(tableAlarm);
    result.forEach((element) {
      var alarmInfo = AlarmInfo.fromMap(element);
      _alarms.add(alarmInfo);
    });

    return _alarms;
  }

  Future<int> delete(int id) async {
    var db = await this.database;
    return await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(int id, AlarmInfo alarmInfo) async {
    var db = await this.database;
    // print("CCCCCCCCCCCCCCCCCCCCCC:${alarmInfo.status}");
    return await db.update(tableAlarm, alarmInfo.toMap(),
        where: '$columnId = ?', whereArgs: [id]);
  }
}
