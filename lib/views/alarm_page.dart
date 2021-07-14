import 'package:repeat_notifications/alarm_helper.dart';
import 'package:repeat_notifications/constants/theme_data.dart';
import 'package:repeat_notifications/models/alarm_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_apps/device_apps.dart';

import '../main.dart';

class AlarmPage extends StatefulWidget {
  AlarmPage({Key? key}) : super(key: key);
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> with WidgetsBindingObserver {
  DateTime? currentBackPressTime;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;
  int minutesRepeat = 0;
  int generateId = -1;
  final controllerTitle = TextEditingController();
  final controllerHour = TextEditingController();
  final controllerMinute = TextEditingController();
  double heightSizeBoxOut = 0;
  double widthSizeBoxOut = 0;
  double fontSizeOut = 0;
  double heightWidgetTextButton = 0;
  double widthWidgetTextButton = 0;
  double sizePopupStyle = 0;
  double borderRadiusSizeOut = 0;
  double allEdgeInsetsOut = 0;

  OverlayEntry? _popupDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _alarmHelper.initializeDatabase().then((value) async {
      print('------database intialized');
      loadAlarms();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    // if (state == AppLifecycleState.paused) {
    //   _alarmHelper
    //       .onReorder(_currentAlarms!); // update index database if app paused
    // }
    if (state == AppLifecycleState.resumed) {
      loadAlarms();
    }
  }

  Future<void> loadAlarms() async {
    var temp = await _alarmHelper.getAlarms();
    _alarms = temp.item1;
    generateId = temp.item2;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double widthSceen = MediaQuery.of(context).size.width; //392.72727272727275
    double widthNextAlarm = (9 / 50) * widthSceen;

    double heightSceen = MediaQuery.of(context).size.height; //759.2727272727273
    double heightSizeBox = heightSceen / 75.92727272727273; //10
    double paddingFolowBy = heightSceen / 23.72727273; //32

    double paddingContainer = widthSceen / 12.85714286; //32
    double borderRadiusSize = widthSceen / 17.14285714; //24

    widthSizeBoxOut = widthSceen / 39.27272727; //10
    heightSizeBoxOut = heightSizeBox;
    fontSizeOut = widthSceen / 19.63636364; // 20
    heightWidgetTextButton = (2 / 3) * widthSceen; //
    widthWidgetTextButton = (1 / 3) * widthSceen; //
    sizePopupStyle = widthSceen;
    borderRadiusSizeOut = borderRadiusSize;
    allEdgeInsetsOut = heightSceen / 41.54285714; // 20
    // print("widthSceen: $widthSceen");
    // print("heightSceen: $heightSceen");
    return WillPopScope(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: paddingContainer, vertical: paddingContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widgetTextTitle("Repeat notifications",
                  fontSize: borderRadiusSize + 1),
              SizedBox(
                height: heightSizeBox,
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
                              var timeNext = alarm.timeAdded
                                  .add(Duration(minutes: alarm.minutesRepeat));

                              var stringNextAlarm =
                                  '${timeNext.hour.toString().padLeft(2, '0')}:${timeNext.minute.toString().padLeft(2, '0')}';
                              return GestureDetector(
                                onTap: () async {
                                  if (titleToTypeOpenApp(alarm.title) ==
                                      'momo') {
                                    DeviceApps.openApp(
                                        'com.mservice.momotransfer');
                                  } else if (titleToTypeOpenApp(alarm.title) ==
                                      'shopee') {
                                    DeviceApps.openApp('com.shopee.vn');
                                  }
                                },
                                key: Key('${alarm.id}'),
                                child: Container(
                                  margin:
                                      EdgeInsets.only(bottom: paddingContainer),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: paddingContainer / 2,
                                      vertical: paddingContainer / 4),
                                  // horizontal: 10,
                                  // vertical: 8),
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
                                        blurRadius: paddingContainer / 4,
                                        spreadRadius: paddingContainer / 16,
                                        offset: Offset(paddingContainer / 8,
                                            paddingContainer / 8),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(borderRadiusSize)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                size: borderRadiusSize,
                                              ),
                                              widgetTextButton(
                                                  alarm.title, alarm.id,
                                                  isTitle: true),
                                            ],
                                          ),
                                          Icon(
                                            Icons.alarm,
                                            color: Colors.white,
                                            size: borderRadiusSize,
                                          ),
                                          Switch(
                                            onChanged: (bool value) {
                                              setState(() {
                                                alarm.status = (value) ? 1 : 0;
                                                updateAlarm(alarm.id, alarm,
                                                    isForSwitch: true);
                                              });
                                            },
                                            value: (alarm.status == 1)
                                                ? true
                                                : false,
                                            activeColor: Colors.white,
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Repeat after',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'avenir'),
                                              ),
                                              widgetTextButton(
                                                  alarmTime, alarm.id),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Next alarm',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'avenir'),
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          loadAlarms();
                                                        });
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          loadAlarms();
                                                        });
                                                        _popupDialog =
                                                            _createPopupDialog(
                                                                timeNext);
                                                        Overlay.of(context)!
                                                            .insert(
                                                                _popupDialog!);
                                                      },
                                                      onLongPressEnd:
                                                          (details) =>
                                                              _popupDialog
                                                                  ?.remove(),
                                                      child: widgetNextAlarm(
                                                          stringNextAlarm,
                                                          alarm.id,
                                                          widthNextAlarm)),
                                                  IconButton(
                                                      icon: Icon(Icons.delete),
                                                      color: Colors.white,
                                                      onPressed: () {
                                                        deleteAlarm(alarm.id,
                                                            alarm.status);
                                                      }),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).followedBy([
                              Container(
                                key: Key("9999"),
                                child: DottedBorder(
                                  strokeWidth: borderRadiusSize / 12,
                                  color: CustomColors.clockOutline,
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(borderRadiusSize),
                                  dashPattern: [
                                    (borderRadiusSize / 6) + 1,
                                    borderRadiusSize / 6
                                  ],
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: CustomColors.clockBG,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(borderRadiusSize)),
                                    ),
                                    child: FlatButton(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: paddingContainer,
                                          vertical: paddingContainer / 2),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          useRootNavigator: true,
                                          context: context,
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                  borderRadiusSize),
                                            ),
                                          ),
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder:
                                                  (context, setModalState) {
                                                return Container(
                                                  padding: EdgeInsets.all(
                                                      paddingFolowBy),
                                                  child: Column(
                                                    children: [
                                                      widgetTextTitle(
                                                          "Duration",
                                                          isWhite: false,
                                                          fontSize:
                                                              borderRadiusSize),
                                                      SizedBox(
                                                          height:
                                                              heightSizeBox),
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
                                                      SizedBox(
                                                          height:
                                                              heightSizeBox),
                                                      widgetTimeDuration(),
                                                      SizedBox(
                                                          height:
                                                              heightSizeBox),
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
                                          SizedBox(height: heightSizeBox),
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
      bool isForTitle = false,
      bool isForNextAlarm = false}) async {
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
        timeAdded: DateTime.now(),
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
        rescheduleOnReboot: true,
      ).then((value) =>
          // Fluttertoast.showToast(
          //     msg:
          //         "Id: $id; StartRepeat: ${value.toString()}; time: ${alarmInfo.minutesRepeat.toString()}"));
          print(
              "Id: $id; StartRepeat: ${value.toString()}; time: ${alarmInfo.minutesRepeat.toString()}"));
    } else {
      if (isForTitle && title.isNotEmpty) {
        var alarmInfo = await _alarmHelper.getOneAlarm(idForUpdate);
        alarmInfo.title = title;
        var idx =
            _currentAlarms!.indexWhere((element) => element.id == idForUpdate);
        _currentAlarms![idx] = alarmInfo;
        _alarmHelper.update(idForUpdate, alarmInfo);
      } else if (isForNextAlarm == false &&
          isForTitle == false &&
          (hText.isNotEmpty || mText.isNotEmpty)) {
        var alarmInfo = await _alarmHelper.getOneAlarm(idForUpdate);
        alarmInfo.minutesRepeat = minutesRepeat;
        updateAlarm(idForUpdate, alarmInfo, isSetState: false);
      } else if (isForNextAlarm == true && isForTitle == false) {
        if (hText.isNotEmpty && mText.isNotEmpty) {
          var alarmInfo = await _alarmHelper.getOneAlarm(idForUpdate);
          var now = DateTime.now();
          var timeNext = DateTime(
              now.year, now.month, now.day, int.parse(hText), int.parse(mText));
          alarmInfo.timeAdded = now;
          alarmInfo.minutesRepeat =
              timeNext.difference(alarmInfo.timeAdded).inMinutes + 1;
          updateAlarm(idForUpdate, alarmInfo, isSetState: false);
        } else {
          Fluttertoast.showToast(
              msg: "Hours and Minutes are not null",
              toastLength: Toast.LENGTH_LONG);
        }
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

  Future<void> deleteAlarm(int id, int status) async {
    _currentAlarms!.removeWhere((element) => element.id == id);
    setState(() {
      _alarms = Future.value(_currentAlarms);
    });
    _alarmHelper.delete(id);
    if (status == 1) {
      await AndroidAlarmManager.cancel(id).then((value) =>
          // Fluttertoast.showToast(
          //     msg: "Id: $id; CancelRepeat: ${value.toString()}"));
          print("Id: $id; CancelRepeat: ${value.toString()}"));
    }
  }

  Future<void> updateAlarm(int id, AlarmInfo alarmInfo,
      {bool isForSwitch = false,
      bool isSetState = true,
      bool isUpdateTimeAdded = true}) async {
    var idx = _currentAlarms!.indexWhere((element) => element.id == id);
    if (isUpdateTimeAdded) {
      alarmInfo.timeAdded = DateTime.now(); // Update time added
    }
    _currentAlarms![idx] = alarmInfo;
    if (isSetState) {
      setState(() {
        _alarms = Future.value(_currentAlarms);
      });
    }
    _alarmHelper.update(id, alarmInfo);
    if (isForSwitch && alarmInfo.status == 0) {
      await AndroidAlarmManager.cancel(id).then((value) =>
          // Fluttertoast.showToast(
          //     msg: "Id: $id; CancelRepeat: ${value.toString()}"));
          print("Id: $id; CancelRepeat: ${value.toString()}"));
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
      ).then((value) =>
          // ).then((value) => Fluttertoast.showToast(
          //     msg:
          //         "Id: $id; StartRepeat: ${value.toString()}   ; time: ${alarmInfo.minutesRepeat.toString()}"));
          print(
              "Id: $id; StartRepeat: ${value.toString()}   ; time: ${alarmInfo.minutesRepeat.toString()}"));
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
              hintText: 'Hours',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: widthSizeBoxOut,
        ),
        Expanded(
          child: TextField(
            controller: controllerMinute,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Minutes',
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
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(borderRadiusSizeOut))),
              child: Container(
                height: heightWidgetTextButton,
                padding: EdgeInsets.all(allEdgeInsetsOut),
                child: Center(
                  child: Column(
                    children: [
                      widgetTextTitle(
                          (isTitle) ? "Change Title" : "Change Duration",
                          isWhite: false,
                          fontSize: fontSizeOut),
                      SizedBox(height: heightSizeBoxOut),
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
                      SizedBox(height: heightSizeBoxOut),
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
              ),
            );
          },
        );
      },
      child: Container(
        width: widthWidgetTextButton,
        child: widgetTextTitle(title, fontSize: fontSizeOut),
      ),
    );
  }

  Widget widgetNextAlarm(String title, int idForUpdate, double widthTextTitle) {
    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(borderRadiusSizeOut))),
              child: Container(
                  height: heightWidgetTextButton,
                  padding: EdgeInsets.all(allEdgeInsetsOut),
                  child: Center(
                    child: Column(
                      children: [
                        widgetTextTitle("Change Next alarm",
                            isWhite: false, fontSize: fontSizeOut),
                        SizedBox(height: heightSizeBoxOut),
                        widgetTimeDuration(),
                        SizedBox(height: heightSizeBoxOut),
                        FloatingActionButton.extended(
                          onPressed: () {
                            onSaveAlarm(
                                isRepeat: false,
                                idForUpdate: idForUpdate,
                                isForNextAlarm: true);
                          },
                          icon: Icon(Icons.alarm),
                          label: Text('Save'),
                        ),
                      ],
                    ),
                  )),
            );
          },
        );
      },
      child: Container(
        width: widthTextTitle,
        child: widgetTextTitle(title, fontSize: fontSizeOut),
      ),
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

  OverlayEntry _createPopupDialog(DateTime timeNext) {
    var timeRemain = timeNext.difference(DateTime.now()).inMinutes;
    var timeShow = durationToString(timeRemain);
    return OverlayEntry(
      builder: (context) => AnimatedDialog(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.all(Radius.circular(borderRadiusSizeOut)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          width: sizePopupStyle,
          height: sizePopupStyle,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widgetTextTitle('Time remaining:',
                    fontSize: fontSizeOut, isWhite: false),
                SizedBox(
                  height: heightSizeBoxOut,
                ),
                widgetTextTitle(timeShow,
                    fontSize: fontSizeOut, isWhite: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showNotification(int id) async {
  // var timeNow = DateTime.now();
  // Fluttertoast.showToast(
  //     msg: "Run at: $timeNow", toastLength: Toast.LENGTH_LONG);
  // print("Run at: $timeNow");

  AlarmHelper _alarmHelper = AlarmHelper();
  var alarmInfo = await _alarmHelper.getOneAlarm(id);
  alarmInfo.timeAdded = DateTime.now();
  _alarmHelper.update(id, alarmInfo);
  if (alarmInfo.status == 1) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.quyvsquy.repeat_notifications',
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
      payload: titleToTypeOpenApp(alarmInfo.title),
    );
  }
}

String titleToTypeOpenApp(String title) {
  String res = '';
  title = title.toLowerCase();
  if (title.contains('heo') || title.contains('momo')) {
    res = 'momo';
  } else if (title.contains('tưới') ||
      title.contains('lắc') ||
      title.contains('shope')) {
    res = 'shopee';
  }
  return res;
}

String durationToString(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}

// This a widget to implement the image scale animation, and background grey out effect.
class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  State<StatefulWidget> createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? opacityAnimation;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    scaleAnimation =
        CurvedAnimation(parent: controller!, curve: Curves.easeOutExpo);
    opacityAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
        CurvedAnimation(parent: controller!, curve: Curves.easeOutExpo));

    controller!.addListener(() => setState(() {}));
    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(opacityAnimation!.value),
      child: Center(
        child: FadeTransition(
          opacity: scaleAnimation!,
          child: ScaleTransition(
            scale: scaleAnimation!,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    controller!.dispose(); // you need this
    super.dispose();
  }
}
