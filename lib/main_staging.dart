import 'package:flutter/material.dart';

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
  
  runApp(config);
  logger.log("running main_staging.dart");
}