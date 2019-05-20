import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void initFirebaseMessagingListener(context) async {
  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('On message $message');
      openLogin(context, message);
    },
    onLaunch: (Map<String, dynamic> message) async {
      print('On launch $message');
      openLogin(context, message);
    },
    onResume: (Map<String, dynamic> message) async {
      print('On resume $message');
      openLogin(context, message);
    },
  );

  _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true));
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    print("Settings registered: $settings");
  });
}

void openLogin(context, message) {
  var data = message['data'];
  if (Platform.isIOS) data = message;

  if (data['type'] == 'login') {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen(data)));
  } else if (data['type'] == 'email_verification') {
    getEmail().then((emailMap) async {
      if (!emailMap['verified']) {
        checkVerificationStatus(await getDoubleName()).then((newEmailMap) async {
          var body = jsonDecode(newEmailMap.body);
          saveEmailVerified(body['verified'] == 1);
        });
      }
    });
  }
}