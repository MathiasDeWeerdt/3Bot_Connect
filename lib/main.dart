import 'package:flutter/material.dart';
import 'package:threebotlogin/config.dart';
import 'package:threebotlogin/screens/HomeScreen.Dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:threebotlogin/services/userService.dart';

List<CameraDescription> cameras;
Config config;
String pk;

Future<void> main() async {
  config = new Config(
    // apiUrl: 'https://login.threefold.me/api'
    apiUrl: 'http://192.168.1.136:5000/api'
  );

  pk = await getPrivateKey();
  try {
    cameras = await availableCameras();
  } on QRReaderException catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3bot',
      theme: ThemeData(
        primaryColor: Color(0xff0f296a),
        accentColor: Color(0xff16a085)
      ),
      routes: {
        '/': (context) => HomeScreen(),
        '/register': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
        '/success': (context) => SuccessfulScreen()
      },
    );
  }
}
