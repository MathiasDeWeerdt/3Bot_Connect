import 'package:flutter/material.dart';

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
  
  runApp(config);
  logger.log("running main_prod.dart");
}