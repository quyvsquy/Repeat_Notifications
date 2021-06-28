import 'package:repeat_notifications/alarm_helper.dart';
import 'package:repeat_notifications/constants/theme_data.dart';
import 'package:repeat_notifications/models/alarm_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../main.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;
  late int minutesRepeat;
  late String titleRepeat;
  final controllerHour = TextEditingController();
  final controllerMinute = TextEditingController();

  @override
  void initState() {
    _alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });

    super.initState();
  }

  void loadAlarms() {
    minutesRepeat = 0;
    titleRepeat = "Noti";
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Alarm',
            style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 24),
          ),
          Expanded(
            child: FutureBuilder<List<AlarmInfo>>(
              future: _alarms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _currentAlarms = snapshot.data;

                  return ListView(
                    children: snapshot.data!.map<Widget>((alarm) {
                      var alarmTime = durationToString(alarm.minutesRepeat);
                      var gradientColor = GradientTemplate
                          .gradientTemplate[alarm.gradientColorIndex].colors;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColor,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColor.last.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(4, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.label,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      alarm.title,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'avenir'),
                                    ),
                                  ],
                                ),
                                Switch(
                                  onChanged: (bool value) {
                                    setState(() {
                                      alarm.status = (value) ? 1 : 0;
                                      updateAlarm(alarm.id!, alarm);
                                    });
                                  },
                                  value: (alarm.status == 1) ? true : false,
                                  activeColor: Colors.white,
                                ),
                              ],
                            ),
                            Text(
                              'Duration repeat (HH:mm)',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'avenir'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  alarmTime,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'avenir',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      deleteAlarm(alarm.id!);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).followedBy([
                      if (_currentAlarms!.length < 5)
                        DottedBorder(
                          strokeWidth: 2,
                          color: CustomColors.clockOutline,
                          borderType: BorderType.RRect,
                          radius: Radius.circular(24),
                          dashPattern: [5, 4],
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: CustomColors.clockBG,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                            ),
                            child: FlatButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              onPressed: () {
                                showModalBottomSheet(
                                  useRootNavigator: true,
                                  context: context,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          padding: const EdgeInsets.all(32),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Duration",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'avenir',
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              SizedBox(height: 10),
                                              TextField(
                                                onChanged: (text) {
                                                  titleRepeat = text;
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: 'Title',
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          controllerHour,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText: 'HH',
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          controllerMinute,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText: 'mm',
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              FloatingActionButton.extended(
                                                onPressed: () {
                                                  onSaveAlarm();
                                                },
                                                icon: Icon(Icons.alarm),
                                                label: Text('Save'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/add_alarm.png',
                                    scale: 1.5,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Alarm',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'avenir'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                            child: Text(
                          'Only 5 alarms allowed!',
                          style: TextStyle(color: Colors.white),
                        )),
                    ]).toList(),
                  );
                }
                return Center(
                  child: Text(
                    'Loading..',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onSaveAlarm() async {
    int hour, minute;
    var hText = controllerHour.text;
    var mText = controllerMinute.text;
    if (hText != '' && mText != '') {
      hour = int.parse(hText) * 60;
      minute = int.parse(mText);
    } else if (mText == '' && hText != '') {
      hour = int.parse(hText) * 60;
      minute = 0;
    } else if (hText == '' && mText != '') {
      hour = 0;
      minute = int.parse(mText);
    } else {
      hour = 0;
      minute = 0;
    }

    minutesRepeat = hour + minute;

    var alarmInfo = AlarmInfo(
      title: (titleRepeat != '') ? titleRepeat : "Noti",
      minutesRepeat: minutesRepeat,
      status: 1,
      gradientColorIndex: _currentAlarms!.length,
    );
    int id = await _alarmHelper.insertAlarm(alarmInfo);

    await AndroidAlarmManager.periodic(
      Duration(minutes: (minutesRepeat != 0) ? minutesRepeat : 1),
      id,
      showNotification,
      exact: true,
      wakeup: true,
    ).then((value) => print(
        "StartRepeat: ${value.toString()};time: ${alarmInfo.minutesRepeat.toString()}"));
    Navigator.pop(context);
    loadAlarms();
  }

  Future<void> deleteAlarm(int id) async {
    _alarmHelper.delete(id);
    loadAlarms();
    await AndroidAlarmManager.cancel(id)
        .then((value) => print("CancelRepeat: ${value.toString()}"));
  }

  Future<void> updateAlarm(int id, AlarmInfo alarmInfo) async {
    _alarmHelper.update(id, alarmInfo);
    loadAlarms();
    if (alarmInfo.status == 0) {
      await AndroidAlarmManager.cancel(id)
          .then((value) => print("CancelRepeat: ${value.toString()}"));
    } else {
      await AndroidAlarmManager.periodic(
        Duration(
            minutes:
                (alarmInfo.minutesRepeat != 0) ? alarmInfo.minutesRepeat : 1),
        id,
        showNotification,
        exact: true,
        wakeup: true,
      ).then((value) => print(
          "StartRepeat: ${value.toString()};time: ${alarmInfo.minutesRepeat.toString()}"));
    }
  }
}

void showNotification(int id) async {
  AlarmHelper _alarmHelper = AlarmHelper();
  var alarmInfo = await _alarmHelper.getOneAlarm(id);
  if (alarmInfo.status == 1) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'chicken_icon',
      playSound: true,
      largeIcon: DrawableResourceAndroidBitmap('chicken_icon'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      id,
      'Alarm Fire',
      alarmInfo.title,
      platformChannelSpecifics,
    );
  }
}

String durationToString(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}
