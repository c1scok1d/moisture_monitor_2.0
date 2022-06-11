import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMsgHandler{
  FirebaseMsgHandler(RemoteMessage message);
  Future<void> onBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Handling a background message ${message.messageId}');
  }
}