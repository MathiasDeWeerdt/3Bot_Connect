import 'dart:convert';

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
  final _AppSelectorState instance = _AppSelectorState();

  void appsCallback() {
    instance.appsCallback();
  }

  @override
  _AppSelectorState createState() => instance;
}

class _AppSelectorState extends State<AppSelector> {
  List<Map<String, dynamic>> apps;
  bool isVisible = true;
  bool hasBrowserBeenInitialized = false;
  bool hasFFPBeenInitialized = false;

  String kAndroidUserAgent =
      'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
  bool isLaunched = false;
  @override
  void initState() {
    super.initState();
    flutterWebViewPlugins[1] = new FlutterWebviewPlugin();
  }

  Future launchFfp(size) async {
    final url = 'https://freeflowpages.com/user/auth/external?authclient=3bot';
    final client = http.Client();
    final request = new http.Request('GET', Uri.parse(url))
      ..followRedirects = false;
    final response = await client.send(request);

    final state =
        Uri.decodeFull(response.headers['location'].split("&state=")[1]);
    final privateKey = await getPrivateKey();
    final signedHash = signHash(state, privateKey);

    final redirecturl = Uri.decodeFull(
        response.headers['location'].split("&redirecturl=")[1].split("&")[0]);
    final appid = Uri.decodeFull(
        response.headers['location'].split("appid=")[1].split("&")[0]);
    final scope = Uri.decodeFull(
        response.headers['location'].split("&scope=")[1].split("&")[0]);
    final publickey = Uri.decodeFull(
        response.headers['location'].split("&publickey=")[1].split("&")[0]);
    final cookies = response.headers['set-cookie'];
    final union = '?';

    final scopeData = {};

    if (scope != null && scope.contains("user:email")) {
      scopeData['email'] = await getEmail();
    }

    var jsonData = jsonEncode(
        (await encrypt(jsonEncode(scopeData), publickey, privateKey)));
    var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();
    var newRedirectUrl =
        '$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(await signedHash)}&data=$data';

    flutterWebViewPlugins[1].launch(newRedirectUrl,
        rect: Rect.fromLTWH(0.0, 75, size.width, size.height - 75),
        userAgent: kAndroidUserAgent,
        hidden: true);
    flutterWebViewPlugins[1].setCookies(cookies);

    logger.log(appid);
    logger.log(newRedirectUrl);
    logger.log(cookies);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final prefsF =  SharedPreferences.getInstance();

    prefsF.then((pres) {
      if (!isLaunched && pres.containsKey('firstvalidation')) {
        isLaunched = true;
        launchFfp(size);
      }
    });

    return Stack(children: <Widget>[
      Container(
          height: 0.7 * size.height,
          child: FutureBuilder(
              future: createList(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: apps.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return SingleApp(apps[index], updateApp);
                      });
                } else
                  return Container();
              }))
    ]);
  }

  Future<List> createList() async {
    apps = [
      {
        "name": 'FreeFlowPages',
        "subheading": 'Where privacy and social media co-exist.',
        "bg": 'ffp.jpg',
        "disabled": false,
        "initialUrl": 'https://freeflowpages.com/',
        "callback": updateApp,
        "visible": false,
        "id": 1
      },
      {
        "name": 'OpenBrowser',
        "subheading": 'By Jimber (Coming soon)',
        "url": 'https://broker.jimber.org',
        "bg": 'jimber.png',
        "disabled": false,
        "initialUrl": 'https://broker.jimber.org',
        "callback": updateApp,
        "visible": false,
        "id": 2
      }
    ];

    return apps;
  }

  void appsCallback() {}

  Future updateApp(app) async {
    if (app['id'] == 1) {
      final emailVer = await getEmail();
      if (emailVer['verified']) {
        final prefs = await SharedPreferences.getInstance();

        if (!prefs.containsKey('firstvalidation')) {
          final size = MediaQuery.of(context).size;
          isLaunched = true;
          launchFfp(size);
          prefs.setBool('firstvalidation', true);
        }
         flutterWebViewPlugins[app['id']].show();
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
