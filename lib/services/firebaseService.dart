import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void initFirebaseMessagingListener(context) async {
  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('On message $message');

      Navigator.popUntil(context, ModalRoute.withName('/'));
      var data = message['data'];
      if (Platform.isIOS) {
        data = message;
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen(data)));
    },
    onLaunch: (Map<String, dynamic> message) async {
      String sentTime;
      if (sentTime != message['data']['google.sent_time']) {
        sentTime = message['data']['google.sent_time'];
        print('On launch $message');

        Navigator.popUntil(context, ModalRoute.withName('/'));
        var data = message['data'];
        if (Platform.isIOS) {
          data = message;
        }
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LoginScreen(data)));
      }
    },
    onResume: (Map<String, dynamic> message) async {
      print('On resume $message');

      Navigator.popUntil(context, ModalRoute.withName('/'));
      var data = message['data'];
      if (Platform.isIOS) {
        data = message;
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen(data)));
    },
  );
  _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true));
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    print("Settings registered: $settings");
  });
}
