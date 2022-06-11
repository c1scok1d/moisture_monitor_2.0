import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMsgHandler{
  FirebaseMsgHandler();
  String sampleData=
      'data:{'
      '"hostname":"abcd",'
      '"component":"humidity",'
      '"value":"50",'
      '"timestamp":"2020-01-01T00:00:00.000Z"'
      '}';
  Future<void> onBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}: ${message.data['hostname']}');
    if(message.data.containsKey('hostname')){
      showMessage(message);
    }else{
      print('No hostname found in message');
    }
  }

  void showMessage(RemoteMessage message) {

  }
}