import 'package:flutter/material.dart';

import 'config.dart';
import 'main.dart';

void main() async {
  var config = Config(
      name: '3bot local',
      threeBotApiUrl: 'http://dev.jimber.org:5000/api',
      openKycApiUrl: 'https://openkyc.staging.jimber.org/',
      threeBotFrontEndUrl: 'http://dev.jimber.org:8080/',
      child: new MyApp());

  init();

  apps = [
    {
      "content": Text(
        'FreeFlowPages',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      "subheading": 'Where privacy and social media co-exist.',
      "bg": 'ffp.jpg',
      "disabled": false,
      "initialUrl": 'https://www2.freeflowpages.com/',
      "visible": false,
      "id": 0,
      'cookieUrl':
          'https://www2.freeflowpages.com/user/auth/external?authclient=3bot',
      'color': 0xFF708fa0,
      'errorText': false,
      'permissions': []
    },
    {
      "content": Text(
        'OpenBrowser',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      "subheading": 'By Jimber',
      // "url": 'https://broker.jimber.org/', anders zit da heelsan te loggen
      "url": 'https://google.com',
      "bg": 'jimber.png',
      "disabled": false,
      // "initialUrl": 'https://broker.jimber.org/',
      "initialUrl": 'https://google.com',
      "visible": false,
      "id": 1,
      'cookieUrl': '',
      'color': 0xFF0f296a,
      'errorText': false,
      'permissions': []
    },
    {
      "content": Text(
        'FreeflowConnect',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      "subheading": '',
      "url": 'https://cowork-lochristi.threefold.work/',
      "bg": 'om.jpg',
      "disabled": false,
      "initialUrl": 'https://cowork-lochristi.threefold.work/',
      "visible": false,
      "id": 2,
      'cookieUrl': '',
      'color': 0xFF0f296a,
      'errorText': false,
      'permissions': ['CAMERA', 'MICROPHONE']
    },
    {
      "content": Text(
        'NBH Digital Wallet',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      "subheading": '',
      "url": 'https://wallet.staging.jimber.org',
      "bg": 'nbh.png',
      "disabled": false,
      "initialUrl": 'https://wallet.staging.jimber.org',
      "visible": false,
      "id": 3,
      'cookieUrl': '',
      'color': 0xFF34495e,
      'errorText': false,
      'permissions': ['CAMERA']
    },
    {
      "content": Icon(
        Icons.add_circle,
        size: 75,
        color: Colors.white,
      ),
      "subheading": 'New Application',
      "bg": 'example.jpg',
      "url": 'https://jimber.org/app',
      "disabled": true,
      "initialUrl": 'https://jimber.org/app',
      "visible": false,
      "id": 4,
      'cookieUrl': '',
      'color': 0xFF0f296a,
      'errorText': false,
      'permissions': []
    }
  ];

  runApp(config);
  logger.log("running main_local_alex.dart");
}
