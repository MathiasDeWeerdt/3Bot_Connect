import 'package:flutter/material.dart';
import 'package:threebotlogin_app/config.dart';
import 'package:threebotlogin_app/screens/HomeScreen.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
List<CameraDescription> cameras;
Config config;

Future<void> main() async {


  config = new Config(
    apiUrl: 'http://192.168.1.85:5000/api'
  );
  cameras = await availableCameras();
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
      home: HomeScreen(),
    );
  }
}
