import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMsgHandler {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  late AndroidNotificationChannel channel;

  FirebaseMsgHandler();

  init() async {
    await Firebase.initializeApp();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'Gage Readings', // title
      description:
          'This channel is used for showing when gage readings go below certain level.',
      // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  String sampleData = 'data:{'
      '"hostname":"abcd",'
      '"component":"humidity",'
      '"value":"50",'
      '"message":"2020-01-01T00:00:00.000Z"'
      '}';

  Future<void> onBackgroundMessage(RemoteMessage message) async {
    print(
        'Handling a background message ${message.messageId}: ${message.data['hostname']}');
    if (message.data.containsKey('hostname')) {
      showMessage(message);
    } else {
      print('No hostname found in message');
    }
  }

  Future<void> showMessage(RemoteMessage message) async {
    print('Showing message:' + message.data['id']);

    await Firebase.initializeApp();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'Gage Readings', // title
      description:
          'This channel is used for showing when gage readings go below certain level.',
      // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var id = 0;
    if((message.data['id'].contains('.'))){
      id = int.parse(message.data['id'].split('.')[0]);
    } else {
      id = int.parse(message.data['id']);
    }
    flutterLocalNotificationsPlugin.show(
      id,
      message.data['hostname'],
      message.data['message'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: 'ic_launcher',
        ),
        iOS: IOSNotificationDetails(
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
