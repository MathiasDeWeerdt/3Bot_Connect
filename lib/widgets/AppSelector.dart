import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:http/http.dart' as http;
import 'package:threebotlogin/widgets/SingleApp.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/toolsService.dart';

import 'package:threebotlogin/services/openKYCService.dart';
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
      'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
  bool isLaunched = false;

  // final GlobalKey<ScaffoldState> _appSelectScaffold = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    for (var app in apps) {
      flutterWebViewPlugins[app['id']] = new FlutterWebviewPlugin();
    }
  }

  Future<void> launchApp(size, appId) async {
    try {
      var url = apps[appId]['cookieUrl'];
      var loadUrl = apps[appId]['url'];

      var localStorageKeys = apps[appId]['localStorageKeys'];

      var cookies = '';
      final union = '?';
      if (url != '') {
        final client = http.Client();
        final request = new http.Request('GET', Uri.parse(url))
          ..followRedirects = false;
        final response = await client.send(request);
        logger.log('-----');
        logger.log(response.headers);
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
        logger.log(response.headers['set-cookie'].toString() + " Lower");
        cookies = response.headers['set-cookie'];

        final scopeData = {};

        if (scope != null && scope.contains("user:email")) {
          scopeData['email'] = await getEmail();
        }

        var jsonData = jsonEncode(
            (await encrypt(jsonEncode(scopeData), publickey, privateKey)));
        var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();
        loadUrl =
            'https://$appName$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(await signedHash)}&data=$data';

        var cookieList = List<Cookie>();
        cookieList.add(Cookie.fromSetCookieValue(cookies));

        flutterWebViewPlugins[appId].launch(loadUrl,
            rect: Rect.fromLTWH(0.0, 75, size.width, size.height - 75),
            userAgent: kAndroidUserAgent,
            hidden: true,
            cookies: cookieList,
            withLocalStorage: true);
      } else if (localStorageKeys != null) {
        await flutterWebViewPlugins[appId].launch(loadUrl + '/error',
            rect: Rect.fromLTWH(0.0, 75, size.width, size.height - 75),
            userAgent: kAndroidUserAgent,
            hidden: true,
            cookies: [],
            withLocalStorage: true);

        var keys = await generateKeyPair();

        final state = randomString(15);

        final privateKey = await getPrivateKey();
        final signedHash = signData(state, privateKey);

        var jsToExecute =
            "(function() { try {window.localStorage.setItem('tempKeys', \'{\"privateKey\": \"${keys["privateKey"]}\", \"publicKey\": \"${keys["publicKey"]}\"}\');  window.localStorage.setItem('state', '$state'); } catch (err) { return err; } })();";
        sleep(const Duration(seconds: 1));
        final res =
            await flutterWebViewPlugins[appId].evalJavascript(jsToExecute);
        final appid = apps[appId]['appid'];
        final redirecturl = apps[appId]['redirecturl'];
        var scope = {};
        scope['doubleName'] = await getDoubleName();
        scope['keys'] = await getKeys(appid, scope['doubleName']);

        var encrypted =
            await encrypt(jsonEncode(scope), keys["publicKey"], privateKey);
        var jsonData = jsonEncode(encrypted);
        var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();

        loadUrl =
            'https://$appid$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(await signedHash)}&data=$data';
        // loadUrl ='https://www.cam-recorder.com/';

        // Wrapped `setItem` into a func that would return some helpful info in case it throws.
        flutterWebViewPlugins[appId].reloadUrl(loadUrl);
        print("Eval result: $res");

        logger.log("Launching App" + [appId].toString());
      } else {
        flutterWebViewPlugins[appId].launch(loadUrl,
            rect: Rect.fromLTWH(0.0, 75, size.width, size.height - 75),
            userAgent: kAndroidUserAgent,
            hidden: true,
            cookies: [],
            withLocalStorage: true);
        logger.log("Launching App" + [appId].toString());
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
      if (!isLaunched && pres.containsKey('firstvalidation')) {
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
                return SingleApp(apps[index], updateApp);
              }))
    ]);
  }

  void sendVerificationEmail() async {
    final snackbarResending = SnackBar(
        content: Text('Resending verification email...'),
        duration: Duration(seconds: 1));
    Scaffold.of(context).showSnackBar(snackbarResending);
    await resendVerificationEmail();
    _showResendEmailDialog();
  }

  void _showResendEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.check,
        title: "Email has been resend.",
        description: new Text("A new verification email has been send."),
        actions: <Widget>[
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

  Future<void> updateApp(app) async {
    if (!app['disabled']) {
      final emailVer = await getEmail();
      if (emailVer['verified']) {
        if (!app['errorText']) {
          final prefs = await SharedPreferences.getInstance();

          if (!prefs.containsKey('firstvalidation')) {
            final size = MediaQuery.of(context).size;
            isLaunched = true;

            for (var oneApp in apps) {
              if (app['id'] != oneApp['id']) {
                logger.log(oneApp['url']);
                logger.log("launching app " + oneApp['id'].toString());
                launchApp(size, oneApp['id']);
              }
            }
            await launchApp(size, app['id']);
            flutterWebViewPlugins[app['id']].show();
            showButton = true;
            prefs.setBool('firstvalidation', true);
          }

          widget.notifyParent(app['color']);
          logger.log("Webviews is showing");
          showButton = true;
          lastAppUsed = app['id'];
          keyboardUsedApp = app['id'];
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
            description: new Text("Please verify email before using this app"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: new Text("Resend email"),
                onPressed: () {
                  sendVerificationEmail();
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
