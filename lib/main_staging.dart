import 'package:flutter/material.dart';

import 'config.dart';
import 'main.dart';

void main() {
  var config = Config(
      name: '3bot staging',
      threeBotApiUrl: 'https://login.staging-01.jimber.lan/api',
      openKycApiUrl: 'https://openkyc.staging-01.jimber.lan',
      child: new MyApp()
  );

  init();
  
  runApp(config);
  print("running main_staging.dart");
}