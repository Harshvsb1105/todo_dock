
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/rxdart.dart';

import 'models/todo_models.dart';

class NotificationPlugin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification> didReceiveNotificationSubject = BehaviorSubject<ReceivedNotification>();
  var initializationSettings;
  TodoItem item;
  TimeOfDay pickedTime;
  String time;


  NotificationPlugin._() {
    init();
  }
  init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics(){
    var initializationSettingsAndroid = AndroidInitializationSettings('todo_dock');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(id: id, title: title, body: body, payload: payload);
        didReceiveNotificationSubject.add(receivedNotification);
      }
    );
    initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
        alert: false,
        sound: true,
        badge: true
    );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions){
    didReceiveNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }
//  Future<void> showNotification() async {
//    var androidChannelSpecific = AndroidNotificationDetails(
//      'CHANNEL_ID',
//      'CHANNEL_NAME',
//      'CHANNEL_DESCRIPTION',
//      importance: Importance.Max,
//      priority: Priority.High,
//      ticker: 'Task Reminder',
//      playSound: true,
//      timeoutAfter: 5000,
//      styleInformation: DefaultStyleInformation(true, true),
//    );
//    var iosChannelSpecific = IOSNotificationDetails();
//    var platformChannelSpecifics = NotificationDetails(androidChannelSpecific, iosChannelSpecific);
//    await flutterLocalNotificationsPlugin.show(
//      0,
//      'Test_Title',
//      'Test_Body',
//      platformChannelSpecifics,
//      payload: 'Test_Payload',
//    );
//  }
//  Future<void> scheduleNotification() async {
//    var scheduleNotificationDateTime = DateTime.parse(item.time);
//    var androidChannelSpecific = AndroidNotificationDetails(
//      'CHANNEL_ID 1',
//      'CHANNEL_NAME 1',
//      'CHANNEL_DESCRIPTION 1',
//      importance: Importance.Max,
//      priority: Priority.High,
//      playSound: true,
//      timeoutAfter: 5000,
//      styleInformation: DefaultStyleInformation(true, true),
//      enableLights: true,
//      color: Color.fromRGBO(255, 255, 0, 0),
//      ledColor: Color.fromRGBO(255, 255, 0, 0),
//      ledOnMs: 1000,
//      ledOffMs: 500,
//      ticker: 'Task Reminder',
//    );
//    var iosChannelSpecific = IOSNotificationDetails();
//    var platformChannelSpecifics = NotificationDetails(androidChannelSpecific, iosChannelSpecific);
//    await flutterLocalNotificationsPlugin.schedule(
//      0,
//      'Test_Title',
//      'Test_Body',
//      scheduleNotificationDateTime,
//      platformChannelSpecifics,
//      payload: 'Test_Payload',
//    );
//  }


    showDailyAtTime(int hour, int minute) async {
    var time = Time(hour, minute, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID ',
      'CHANNEL_NAME ',
      "CHANNEL_DESCRIPTION ",
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'Task Reminder',
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
    NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'Time to do the task',
      'Best of Luck', //null
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

}

NotificationPlugin notificationPlugin = NotificationPlugin._();

class ReceivedNotification{
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload
});
}