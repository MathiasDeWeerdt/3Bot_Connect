import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin_app/screens/LoginScreen.dart';
import 'package:threebotlogin_app/screens/ScanScreen.dart';

class HomeScreen extends StatefulWidget {
  final Widget homeScreen;

  HomeScreen({Key key, this.homeScreen}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('On message $message');
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(message: message['data'])));
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('On launch $message');
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(message: message['data'])));
        },
        onResume: (Map<String, dynamic> message) async {
          print('On resume $message');
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(message: message['data'])));
        },
      );
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('3Bot'),
        ),
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ScanScreen()));
              },
              child: Text("Go to scanscreen"),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: Text("Go to Login"),
            )
          ],
        )));
  }
}
