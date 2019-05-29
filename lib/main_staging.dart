import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'main.dart';

void main() {
  var config = Config(
      name: '3bot staging',
      threeBotApiUrl: 'https://login.staging.jimber.org/api',
      openKycApiUrl: 'https://openkyc.staging.jimber.org',
      child: new MyApp()
  );

  init();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(config);
      print("running main_staging.dart");
    });
}