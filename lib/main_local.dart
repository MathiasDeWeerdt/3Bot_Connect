import 'package:flutter/material.dart';

import 'config.dart';
import 'main.dart';

void main() {
  var config = Config(
      name: '3bot local',
      threeBotApiUrl: 'http://0.0.0.0:5000/api',
      openKycApiUrl: 'http://0.0.0.0:5005',
      child: new MyApp()
  );
  
  init();

  runApp(config);
  logger.log("running main_local.dart");
}