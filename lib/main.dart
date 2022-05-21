import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rodland_farms/data/dummy.dart';
import 'package:rodland_farms/screens/authentication/register.dart';
import 'package:rodland_farms/screens/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

