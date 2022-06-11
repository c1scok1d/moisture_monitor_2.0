import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rodland_farms/data/dummy.dart';
import 'package:rodland_farms/notifications/firebase_msg_handler.dart';
import 'package:rodland_farms/screens/authentication/register.dart';
import 'package:rodland_farms/screens/home_page.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _requestPermissions();
  FirebaseMessaging.onBackgroundMessage(FirebaseMsgHandler().onBackgroundMessage);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'Gage Readings', // title
      description: 'This channel is used for showing when gage readings go below certain level.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    // final IOSInitializationSettings initializationSettingsIOS =
    // IOSInitializationSettings(
    //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings();

    // final InitializationSettings initializationSettings = InitializationSettings(
    //     android: initializationSettingsAndroid,
    //     iOS: initializationSettingsIOS,
    //     macOS: initializationSettingsMacOS);
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: selectNotification);
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<User?>(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          print("MaterialApp:"+snapshot.connectionState.name);
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
      ),
      builder: EasyLoading.init(),
    );
  }
  Future<User?> getCurrentUser()  async {
    // GoogleSignIn().signOut();
    // await FirebaseAuth.instance.signOut();
    // print(Dummy().getRecords("deviceId")[0].humid);
    User? _user = await FirebaseAuth.instance.currentUser;
    print("UserUID: ${_user?.uid ?? "None"}");
    print("User: ${_user==null ? "Null" : _user.uid}");
    return _user;}
}

