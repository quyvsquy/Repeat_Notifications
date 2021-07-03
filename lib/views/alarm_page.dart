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
  double heightSizeBoxOut = 0;
  double widthSizeBoxOut = 0;
  double fontSizeOut = 0;
  double heightWidgetTextButton = 0;
  double widthWidgetTextButton = 0;
  double sizePopupStyle = 0;
  double borderRadiusSizeOut = 0;
  OverlayEntry? _popupDialog;

  @override
  void initState() {
    _alarmHelper.initializeDatabase().then((value) async {
      print('------database intialized');
      loadAlarms();
    });

    super.initState();
  }

  Future<void> loadAlarms() async {
    var temp = await _alarmHelper.getAlarms();
    _alarms = temp.item1;
    generateId = temp.item2;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double widthSceen = MediaQuery.of(context).size.width; //411.42857142857144
    double widthSizeBox = widthSceen / 41.142857142857144; //10
    double widthSizeBox2 = widthSceen / 2.95991778;

    double heightSceen = MediaQuery.of(context).size.height; //830.8571428571429
    double heightSizeBox = heightSceen / 83.08571428571429; //10

    double paddingContainer = widthSceen / 12.85714286; //32
    double borderRadiusSize = widthSceen / 17.14285714; //24

    widthSizeBoxOut = widthSizeBox;
    heightSizeBoxOut = heightSizeBox;
    fontSizeOut = borderRadiusSize;
    heightWidgetTextButton = heightSceen / 4.372932331;
    widthWidgetTextButton = widthSceen / 2.285714286; // 180
    sizePopupStyle = widthSceen;
    borderRadiusSizeOut = borderRadiusSize;

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
                              return Container(
                                key: Key('${alarm.id}'),
                                margin:
                                    EdgeInsets.only(bottom: paddingContainer),
                                padding: EdgeInsets.symmetric(
                                    horizontal: paddingContainer / 2,
                                    vertical: paddingContainer / 4),
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
                                              size: borderRadiusSize,
                                            ),
                                            SizedBox(width: widthSizeBox),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Repeat after',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'avenir'),
                                        ),
                                        SizedBox(
                                          width: widthSizeBox2,
                                        ),
                                        Text(
                                          'Next alarm',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'avenir'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        widgetTextButton(alarmTime, alarm.id),
                                        GestureDetector(
                                          onLongPress: () {
                                            setState(() {
                                              loadAlarms();
                                            });
                                            _popupDialog =
                                                _createPopupDialog(timeNext);
                                            Overlay.of(context)!
                                                .insert(_popupDialog!);
                                          },
                                          onLongPressEnd: (details) =>
                                              _popupDialog?.remove(),
                                          child: widgetTextTitle(
                                              stringNextAlarm,
                                              fontSize: fontSizeOut),
                                        ),
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
                                                  padding:
                                                      const EdgeInsets.all(32),
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
      ).then((value) => print(
          "StartRepeat: ${value.toString()};time: ${alarmInfo.minutesRepeat.toString()}"));
    } else {
      if (isForTitle && title.isNotEmpty) {
        var alarmInfo = await _alarmHelper.getOneAlarm(idForUpdate);
        alarmInfo.title = title;
        updateAlarm(idForUpdate, alarmInfo,
            isSetState: false, isUpdateTimeAdded: false);
        _alarmHelper.update(idForUpdate, alarmInfo);
      } else if (isForTitle == false &&
          (hText.isNotEmpty || mText.isNotEmpty)) {
        var alarmInfo = await _alarmHelper.getOneAlarm(idForUpdate);
        alarmInfo.minutesRepeat = minutesRepeat;
        updateAlarm(idForUpdate, alarmInfo, isSetState: false);
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

  Future<void> updateAlarm(int id, AlarmInfo alarmInfo,
      {bool isSetState = true, bool isUpdateTimeAdded = true}) async {
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
    await AndroidAlarmManager.cancel(id)
        .then((value) => print("CancelRepeat: ${value.toString()}"));
    if (alarmInfo.status == 1) {
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
              child: Container(
                height: heightWidgetTextButton,
                padding: const EdgeInsets.all(20),
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
                widgetTextTitle('Time remaining (minutes):',
                    fontSize: fontSizeOut, isWhite: false),
                SizedBox(
                  height: heightSizeBoxOut,
                ),
                widgetTextTitle(timeRemain.toString(),
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
    );
  }
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
