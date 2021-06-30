import 'package:repeat_notifications/models/alarm_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tuple/tuple.dart';

final String tableAlarm = 'alarm';
final String columnId = 'id';
final String columnIdx = 'idx';
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
          $columnId integer primary key not null, 
          $columnIdx integer, 
          $columnTitle text not null,
          $columnDateTime integer not null,
          $columnStatus integer,
          $columnColorIndex integer)
        ''');
        // db.execute('''
        // CREATE TRIGGER IF NOT EXISTS increment_tax_number
        //   AFTER INSERT ON $tableAlarm
        //   BEGIN
        //       UPDATE $tableAlarm SET idx = new.id WHERE id =  new.id;
        //   END;
        // ''');
      },
    );

    return database;
  }

  Future<int> insertAlarm(AlarmInfo alarmInfo) async {
    var db = await this.database;
    var result = await db.insert(tableAlarm, alarmInfo.toMap());
    return result;
  }

  Future<AlarmInfo> getOneAlarm(int id) async {
    var db = await this.database;
    var result =
        await db.query(tableAlarm, where: '$columnId = ?', whereArgs: [id]);

    return AlarmInfo.fromMap(result[0]);
  }

  Future<Tuple2<Future<List<AlarmInfo>>, int>> getAlarms() async {
    List<AlarmInfo> _alarms = [];
    int max = -1;
    var db = await this.database;
    var result = await db.query(tableAlarm, orderBy: columnIdx);

    result.forEach((element) {
      var alarmInfo = AlarmInfo.fromMap(element);
      if (max < alarmInfo.id) max = alarmInfo.id;
      _alarms.add(alarmInfo);
    });
    return Tuple2<Future<List<AlarmInfo>>, int>(Future.value(_alarms), max);
  }

  Future<int> delete(int id) async {
    var db = await this.database;
    return await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(int id, AlarmInfo alarmInfo) async {
    var db = await this.database;
    return await db.update(tableAlarm, alarmInfo.toMap(),
        where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> onReorder(List<AlarmInfo> alarmInfo) async {
    var db = await this.database;
    await db.delete(tableAlarm);
    for (var ia = 0; ia < alarmInfo.length; ia++) {
      var t = alarmInfo[ia];
      t.idx = ia;
      await db.insert(tableAlarm, t.toMap());
    }
  }
}
