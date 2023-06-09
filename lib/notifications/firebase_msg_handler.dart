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
      'Gauge Readings', // title
      description:
          'This channel is used for showing when gauge reading alerts.',
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
    if (kDebugMode) {
      print(
        'Handling a background message ${message.messageId}: ${message.data['hostname']}');
    }
    if (message.data.containsKey('hostname')) {
      showMessage(message);
    } else {
      if (kDebugMode) {
        print('No hostname found in message');
      }
    }
  }

  Future<void> showMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Showing message:' + message.data['id']);
    }

    await Firebase.initializeApp();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'Gauge Readings', // title
      description:
          'This channel is used for showing alerts when gauge readings go below a specified level.',
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
        iOS: const IOSNotificationDetails(
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
