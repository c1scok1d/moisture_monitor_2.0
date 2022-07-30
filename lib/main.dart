

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rodland_farms/notifications/firebase_msg_handler.dart';
import 'package:rodland_farms/screens/authentication/register.dart';
import 'package:rodland_farms/screens/home_page.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'data/received_notifications.dart';


late AndroidNotificationChannel channel;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void _requestPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

String? selectedNotificationPayload;
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();
final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();
Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('MAIN:onBackgroundMessage: ${message.messageId}');
  FirebaseMsgHandler().onBackgroundMessage(message);
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('onMessage: $message');
    FirebaseMsgHandler().showMessage(message);
  });

  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'Gage Readings', // title
      description:
          'This channel is used for showing when gage readings go below certain level.',
      // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    }
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    // final IOSInitializationSettings initializationSettingsIOS =
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (
              int id,
              String? title,
              String? body,
              String? payload,
            ) async {
              didReceiveLocalNotificationSubject.add(
                ReceivedNotification(
                  id: id,
                  title: title,
                  body: body,
                  payload: payload,
                ),
              );
            });

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectedNotificationPayload = payload;
      selectNotificationSubject.add(payload);
    });
    _requestPermissions();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rodland Farms @Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      home: ShowCaseWidget(
        onStart: (index, key) {
          print('onStart: $index, $key');
          SharedPreferences.getInstance().then((prefs) {
            print('INIT:isFirstTime: ${prefs.getBool('isFirstTime')}');
            // prefs.remove('isFirstTime');
          });
        },
        onComplete: (index, key) {
          print('onComplete: $index, $key');
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool('isFirstTime', false);
          });
          if (index == 4) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle.light.copyWith(
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.white,
              ),
            );
          }
        },
        blurValue: 1,
        builder: Builder(builder: (context) {
          return FutureBuilder<User?>(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              print("MaterialApp:" + snapshot.connectionState.name);
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return HomePage();
                } else {
                  return RegisterPage();
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        }),
        autoPlayDelay: const Duration(seconds: 3),
      ),
      builder: EasyLoading.init(),
    );
  }

  Future<User?> getCurrentUser() async {
    // GoogleSignIn().signOut();
    // await FirebaseAuth.instance.signOut();
    // print(Dummy().getRecords("deviceId")[0].humid);
    User? _user = await FirebaseAuth.instance.currentUser;
    print("UserUID: ${_user?.uid ?? "None"}");
    print("User: ${_user == null ? "Null" : _user.uid}");
    return _user;
  }
}
