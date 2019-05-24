import 'package:flutter/material.dart';

import 'config.dart';
import 'main.dart';

void main() {
  var config = Config(
      name: '3bot local',
      threeBotApiUrl: 'http://192.168.1.109:5000/api',
      openKycApiUrl: 'http://192.168.1.109:5005',
      child: new MyApp()
  );
  
  init();

  runApp(config);
  print("running main_local.dart");
}