import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'main.dart';

void main() {
  var config = Config(
      name: '3bot',
      threeBotApiUrl: 'https://login.threefold.me/api',
      openKycApiUrl: 'https://openkyc.live/',
      child: new MyApp()
  );

  init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(config);
      print("running main_prod.dart");
    });
}