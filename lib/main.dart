import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/screens/ErrorScreen.dart';
import 'package:threebotlogin/screens/ProfileScreen.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:threebotlogin/services/userService.dart';

List<CameraDescription> cameras;
String pk;
String deviceId;
Config config;

void init() async {
  pk = await getPrivateKey();

  try {
    cameras = await availableCameras();
  } on QRReaderException catch (e) {
    print(e);
  }

  FirebaseMessaging messaging = FirebaseMessaging();

  messaging.requestNotificationPermissions();
  messaging.getToken().then((t) {
    deviceId = t;
    print('Got device id $deviceId');
  });
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    config = Config.of(context);

    return MaterialApp(
      title: config.name,
      theme: ThemeData(
          primaryColor: Color(0xff0f296a), accentColor: Color(0xff16a085)),
      routes: {
        '/': (context) => HomeScreen(),
        '/scan': (context) => RegistrationScreen(),
        '/register': (context) => RegistrationScreen(),
        '/success': (context) => SuccessfulScreen(),
        '/profile': (context) => ProfileScreen(),
        '/error': (context) => ErrorScreen()
      },
    );
  }
}