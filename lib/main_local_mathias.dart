import 'package:flutter/material.dart';
import 'package:threebotlogin/services/cryptoService.dart';

import 'config.dart';
import 'main.dart';

void main() async {

  // generateKeypair('hello');
  await generateDerivativeKeypair("hello2", "");

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