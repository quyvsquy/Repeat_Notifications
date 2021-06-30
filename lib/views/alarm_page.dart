import 'package:repeat_notifications/alarm_helper.dart';
import 'package:repeat_notifications/constants/theme_data.dart';
import 'package:repeat_notifications/models/alarm_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';

class AlarmPage extends StatefulWidget {
  AlarmPage({Key? key}) : super(key: key);
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? currentBackPressTime;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;
  int minutesRepeat = 0;
  int generateId = -1;
  final controllerTitle = TextEditingController();
  final controllerHour = TextEditingController();
  final controllerMinute = TextEditingController();

  @override
  void initState() {
    _alarmHelper.initializeDatabase().then((value) async {
      print('------database intialized');
      var temp = await _alarmHelper.getAlarms();
      _alarms = temp.item1;
      generateId = temp.item2;
      if (mounted) setState(() {});
    });

    super.initState();
  }

  // void loadAlarms() {
  //   minutesRepeat = 0;
  //   _alarms = _alarmHelper.getAlarms();
  //   if (mounted) setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widgetTextTitle("Repeat notifications"),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: FutureBuilder<List<AlarmInfo>>(
                  future: _alarms,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _currentAlarms = snapshot.data;
                      return Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: ReorderableListView(
                            children: _currentAlarms!.map<Widget>((alarm) {
                              var alarmTime =
                                  durationToString(alarm.minutesRepeat);
                              var gradientColor = GradientTemplate
                                  .gradientTemplate[alarm.gradientColorIndex]
                                  .colors;
                              return Container(
                                key: Key('${alarm.id}'),
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
                                      color:
                                          gradientColor.last.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: Offset(4, 4),
                                    ),
                                  ],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.label,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            SizedBox(width: 10),
                                            widgetTextButton(
                                                alarm.title, alarm.id,
                                                isTitle: true),
                                          ],
                                        ),
                                        Switch(
                                          onChanged: (bool value) {
                                            setState(() {
                                              alarm.status = (value) ? 1 : 0;
                                              updateAlarm(alarm.id, alarm);
                                            });
                                          },
                                          value: (alarm.status == 1)
                                              ? true
                                              : false,
                                          activeColor: Colors.white,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Repeat after (HH:mm)',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'avenir'),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        widgetTextButton(alarmTime, alarm.id),
                                        IconButton(
                                            icon: Icon(Icons.delete),
                                            color: Colors.white,
                                            onPressed: () {
                                              deleteAlarm(alarm.id);
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).followedBy([
                              Container(
                                key: Key("9999"),
                                child: DottedBorder(
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
                                              builder:
                                                  (context, setModalState) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.all(32),
                                                  child: Column(
                                                    children: [
                                                      widgetTextTitle(
                                                          "Duration",
                                                          isWhite: false),
                                                      SizedBox(height: 10),
                                                      TextField(
                                                        controller:
                                                            controllerTitle,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText: 'Title',
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      widgetTimeDuration(),
                                                      SizedBox(height: 10),
                                                      FloatingActionButton
                                                          .extended(
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
                                            'Add Repeat',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'avenir'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ]).toList(),
                            onReorder: _onReorder,
                          ));
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
        ),
        onWillPop: onWillPop);
  }

  Future<void> onSaveAlarm(
      {bool isRepeat = true,
      int idForUpdate = -1,
      bool isForTitle = false}) async {
    int hour, minute;
    var title = controllerTitle.text;
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

    if (isRepeat) {
      generateId += 1;
      var alarmInfo = AlarmInfo(
        id: generateId,
        idx: generateId,
        title: (title != '') ? title : "Noti",
        minutesRepeat: minutesRepeat,
        status: 1,
        gradientColorIndex: _currentAlarms!.length % 5,
      );
      int id = await _alarmHelper.insertAlarm(alarmInfo);
      _currentAlarms!.add(alarmInfo);
      await AndroidAlarmManager.periodic(
        Duration(minutes: (minutesRepeat != 0) ? minutesRepeat : 1),
        id,
        showNotification,
        exact: true,
        wakeup: true,
      ).then((value) => print(
          "StartRepeat: ${value.toString()};time: ${alarmInfo.minutesRepeat.toString()}"));
    } else {
      if (isForTitle && title.isNotEmpty) {
        var alarmInfo = await _alarmHelper.getOneAlarm(idForUpdate);
        var idx =
            _currentAlarms!.indexWhere((element) => element.id == idForUpdate);
        _currentAlarms![idx].title = title;
        alarmInfo.title = title;
        _alarmHelper.update(idForUpdate, alarmInfo);
      } else if (isForTitle == false &&
          (hText.isNotEmpty || mText.isNotEmpty)) {
        var alarmInfo = await _alarmHelper.getOneAlarm(idForUpdate);
        var idx =
            _currentAlarms!.indexWhere((element) => element.id == idForUpdate);
        _currentAlarms![idx].minutesRepeat = minutesRepeat;
        alarmInfo.minutesRepeat = minutesRepeat;
        _alarmHelper.update(idForUpdate, alarmInfo);
      }
    }
    // print("=" * 50);
    // _currentAlarms!.forEach((element) {
    //   print(element.toMap());
    // });
    // print("=" * 50);
    Navigator.pop(context);
    setState(() {
      _alarms = Future.value(_currentAlarms);
    });
  }

  Future<void> deleteAlarm(int id) async {
    _currentAlarms!.removeWhere((element) => element.id == id);
    setState(() {
      _alarms = Future.value(_currentAlarms);
    });
    _alarmHelper.delete(id);
    await AndroidAlarmManager.cancel(id)
        .then((value) => print("CancelRepeat: ${value.toString()}"));
  }

  Future<void> updateAlarm(int id, AlarmInfo alarmInfo) async {
    var idx = _currentAlarms!.indexWhere((element) => element.id == id);
    _currentAlarms![idx] = alarmInfo;
    setState(() {
      _alarms = Future.value(_currentAlarms);
    });
    _alarmHelper.update(id, alarmInfo);
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

  Widget widgetTimeDuration() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controllerHour,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'HH',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            controller: controllerMinute,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'mm',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget widgetTextTitle(String title,
      {bool isWhite = true, double fontSize = 24}) {
    return Text(
      title,
      style: TextStyle(
          color: (isWhite) ? Colors.white : Colors.black,
          fontFamily: 'avenir',
          fontSize: fontSize,
          fontWeight: FontWeight.w700),
    );
  }

  Widget widgetTextButton(String title, int idForUpdate,
      {bool isTitle = false}) {
    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return Dialog(
              child: Container(
                height: 190,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    widgetTextTitle(
                        (isTitle) ? "Change Title" : "Change Duration",
                        isWhite: false),
                    SizedBox(height: 10),
                    (isTitle)
                        ? TextField(
                            controller: controllerTitle,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Title',
                            ),
                            autofocus: true,
                          )
                        : widgetTimeDuration(),
                    SizedBox(height: 10),
                    FloatingActionButton.extended(
                      onPressed: () {
                        if (isTitle) {
                          onSaveAlarm(
                            isRepeat: false,
                            idForUpdate: idForUpdate,
                            isForTitle: true,
                          );
                        } else {
                          onSaveAlarm(
                              isRepeat: false, idForUpdate: idForUpdate);
                        }
                      },
                      icon: Icon(Icons.alarm),
                      label: Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: widgetTextTitle(title),
    );
  }

  void _onReorder(int oldIndex, int newIndex) async {
    var lenCurrentAlarm = _currentAlarms!.length;
    if (oldIndex < lenCurrentAlarm) {
      if (newIndex > lenCurrentAlarm) newIndex = lenCurrentAlarm;
      if (oldIndex < newIndex) newIndex -= 1;

      setState(() {
        final AlarmInfo item = _currentAlarms![oldIndex];
        _currentAlarms!.removeAt(oldIndex);
        _currentAlarms!.insert(newIndex, item);
        _alarms = Future.value(_currentAlarms);
      });
      _alarmHelper.onReorder(_currentAlarms!);
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Click Back again to exit");
      // _alarmHelper.onReorder(_currentAlarms!);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

void showNotification(int id) async {
  AlarmHelper _alarmHelper = AlarmHelper();
  var alarmInfo = await _alarmHelper.getOneAlarm(id);
  if (alarmInfo.status == 1) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'quyvsquy',
      'RepeatApp',
      'Repeat the notification after a period of time',
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
