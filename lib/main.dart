import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:threebotlogin/screens/PreferenceScreen.dart';
import 'package:threebotlogin/services/loggingService.dart';
import 'config.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/screens/RegistrationScreen.dart';
import 'package:threebotlogin/screens/SuccessfulScreen.dart';
import 'package:threebotlogin/screens/ErrorScreen.dart';
import 'package:threebotlogin/screens/RecoverScreen.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:threebotlogin/services/userService.dart';

FirebaseMessaging messaging = FirebaseMessaging();
List<CameraDescription> cameras;
String pk;
String deviceId;
Config config;
LoggingService logger;
List<FlutterWebviewPlugin> flutterWebViewPlugins = new List(6);

List<Map<String, dynamic>> apps = [
  {
    "name": 'FreeFlowPages',
    "subheading": 'Where privacy and social media co-exist.',
    "bg": 'ffp.jpg',
    "disabled": false,
    "initialUrl": 'https://freeflowpages.com/',
    "visible": false,
    "id": 0,
    'cookieUrl': 'https://freeflowpages.com/user/auth/external?authclient=3bot'
  },
  {
    "name": 'OpenBrowser',
    "subheading": 'By Jimber (Coming soon)',
    "url": 'https://broker.jimber.org',
    "bg": 'jimber.png',
    "disabled": false,
    "initialUrl": 'https://broker.jimber.org',
    "visible": false,
    "id": 1,
    'cookieUrl': ''
  }
];


void init() async {
  logger = new LoggingService();

  pk = await getPrivateKey();

  try {
    cameras = await availableCameras();
  } on QRReaderException catch (e) {
    print(e);
  }

  messaging.requestNotificationPermissions();
  messaging.getToken().then((t) {
    deviceId = t;
    logger.log('Got device id $deviceId');
  });
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

String kAndroidUserAgent =
    //'Mozilla/5.0 (Linux; Android 8.0.0; SM-G960F Build/R16NW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36';
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

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
        '/error': (context) => ErrorScreen(),
        '/recover': (context) => RecoverScreen(),
        '/preference': (context) => PreferenceScreen()
      },
    );
  }
}
