import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'main.dart';

void main() {
  var config = Config(
      name: '3bot local',
      threeBotApiUrl: 'http://192.168.2.80:5000/api',
      openKycApiUrl: 'http://192.168.2.80:5005',
      child: new MyApp()
  );
  
  init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(config);
      logger.log("running main_local.dart");
    });
}