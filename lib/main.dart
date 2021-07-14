import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:repeat_notifications/views/alarm_page.dart';
import 'package:repeat_notifications/constants/theme_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:device_apps/device_apps.dart';
import 'package:repeat_notifications/alarm_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('chicken_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
      var listSplit = payload.split(':');
      String type = listSplit[0];
      int id = int.parse(listSplit[1]);
      AlarmHelper _alarmHelper = AlarmHelper();
      var alarmInfo = await _alarmHelper.getOneAlarm(id);
      alarmInfo.timeAdded = DateTime.now();
      _alarmHelper.update(id, alarmInfo);
      if (alarmInfo.status == 0) {
        await AndroidAlarmManager.cancel(id).then(
            (value) => print("Id: $id; CancelRepeat: ${value.toString()}"));
      } else if (alarmInfo.status == 1) {
        await AndroidAlarmManager.periodic(
          Duration(
              minutes:
                  (alarmInfo.minutesRepeat != 0) ? alarmInfo.minutesRepeat : 1),
          id,
          showNotification,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        ).then((value) => print(
            "Id: $id; StartRepeat: ${value.toString()}   ; time: ${alarmInfo.minutesRepeat.toString()}"));
      }
      if (type == 'momo') {
        DeviceApps.openApp('com.mservice.momotransfer');
      } else if (type == 'shopee') {
        DeviceApps.openApp('com.shopee.vn');
      }
    }
  });
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Repeat Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: CustomColors.pageBackgroundColor,
        body: AlarmPage(),
      ),
    );
  }
}
