import 'package:flutter/material.dart';
import 'package:threebotlogin_app/screens/HomeScreen.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;
Future<void> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // logError(e.code, e.description);
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
      home: HomeScreen(),
    );
  }
}
