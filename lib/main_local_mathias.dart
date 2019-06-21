import 'package:flutter/material.dart';

import 'config.dart';
import 'main.dart';
import 'package:threebotlogin/services/cryptoService.dart';

void main() {

  generateKeypair('hello');

  var config = Config(
      name: '3bot local',
      threeBotApiUrl: 'http://192.168.2.60:5000/api',
      openKycApiUrl: 'http://192.168.2.60:5005',
      child: new MyApp()
  );
  
  init();

  runApp(config);
  logger.log("running main_local_mathias.dart");
}