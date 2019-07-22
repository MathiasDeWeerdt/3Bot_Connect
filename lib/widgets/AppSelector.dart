import 'dart:convert';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/widgets/SingleApp.dart';
import 'package:threebotlogin/main.dart';

import 'CustomDialog.dart';

class AppSelector extends StatefulWidget {
  final Function(int colorData) notifyParent;
  final _AppSelectorState instance = _AppSelectorState();

  AppSelector({Key key, this.notifyParent}) : super(key: key);

  @override
  _AppSelectorState createState() => instance;
}

class _AppSelectorState extends State<AppSelector> {
  String kAndroidUserAgent =
      //'Mozilla/5.0 (Linux; Android 8.0.0; SM-G960F Build/R16NW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36';
      'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
  bool isLaunched = false;
  @override
  void initState() {
    super.initState();
    for (var app in apps) {
      logger.log("adding app webplugin " + app['id'].toString());
      flutterWebViewPlugins[app['id']] = new FlutterWebviewPlugin();
    }
  }

  Future launchApp(size, appId) async {
    try {
      //final url = 'https://freeflowpages.com/user/auth/external?authclient=3bot';
      var url = apps[appId]['cookieUrl'];
      var loadUrl = apps[appId]['url'];

      var cookies = '';
      if (url != '') {
        final client = http.Client();
        final request = new http.Request('GET', Uri.parse(url))
          ..followRedirects = false;
        final response = await client.send(request);

        final state =
            Uri.decodeFull(response.headers['location'].split("&state=")[1]);
        final privateKey = await getPrivateKey();
        final signedHash = signData(state, privateKey);

        final redirecturl = Uri.decodeFull(response.headers['location']
            .split("&redirecturl=")[1]
            .split("&")[0]);
        final appName = Uri.decodeFull(
            response.headers['location'].split("appid=")[1].split("&")[0]);
        logger.log(appName);
        final scope = Uri.decodeFull(
            response.headers['location'].split("&scope=")[1].split("&")[0]);
        final publickey = Uri.decodeFull(
            response.headers['location'].split("&publickey=")[1].split("&")[0]);
        cookies = response.headers['set-cookie'];
        final union = '?';

        final scopeData = {};

        if (scope != null && scope.contains("user:email")) {
          scopeData['email'] = await getEmail();
        }

        var jsonData = jsonEncode(
            (await encrypt(jsonEncode(scopeData), publickey, privateKey)));
        var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();
        loadUrl =
            '$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(await signedHash)}&data=$data';
      }

      flutterWebViewPlugins[appId].launch(loadUrl,
          rect: Rect.fromLTWH(0.0, 75, size.width, size.height - 75),
          userAgent: kAndroidUserAgent,
          hidden: true);

      if (cookies != '') {
        flutterWebViewPlugins[appId].setCookies(cookies);
      }

      logger.log(loadUrl);
      logger.log(cookies);
    } on NoSuchMethodError catch (exception) {
      logger.log('error caught: $exception');
      apps[appId]['errorText'] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final prefsF = SharedPreferences.getInstance();

    prefsF.then((pres) {
      if (!isLaunched && pres.containsKey('firstValidation')) {
        isLaunched = true;
        for (var app in apps) {
          logger.log(app['url']);
          logger.log("launching app " + app['id'].toString());
          launchApp(size, app['id']);
        }
      }
    });

    return Stack(children: <Widget>[
      Container(
          height: 0.7 * size.height,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: apps.length,
              itemBuilder: (BuildContext ctxt, int index) {
                logger.log("adding app " + index.toString());

                return SingleApp(apps[index], updateApp);
              }))
    ]);
  }

  Future updateApp(app) async {
    if (!app['disabled']) {
      final emailVer = await getEmail();
      if (emailVer['verified']) {
        if (!app['errorText']) {
          final prefs = await SharedPreferences.getInstance();

          if (!prefs.containsKey('firstValidation')) {
            final size = MediaQuery.of(context).size;
            isLaunched = true;
            launchApp(size, app['id']);
            prefs.setBool('firstValidation', true);
          }

          widget.notifyParent(app['color']);
          flutterWebViewPlugins[app['id']].show();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
                  image: Icons.error,
                  title: "Service Unavailable",
                  description: new Text("Service Unavailable"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    FlatButton(
                      child: new Text("Ok"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                image: Icons.error,
                title: "Please verify email",
                description:
                    new Text("Please verify email before using this app"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  FlatButton(
                    child: new Text("Ok"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              image: Icons.error,
              title: "Coming soon",
              description: new Text("This will be available soon."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: new Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
      );
    }
  }
}
