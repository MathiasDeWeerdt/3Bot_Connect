import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/SingleApp.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppSelector extends StatefulWidget {
  AppSelector({Key key}) : super(key: key);

  _AppSelectorState createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  List<Map<String, dynamic>> apps;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Select your app"),
          Container(
              height: 0.7 * size.height,
              child: FutureBuilder(
                  future: createList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      print(apps);
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: apps.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            print(apps[index]);
                            return SingleApp(
                              apps[index],
                            );
                          });
                    } else return Container();
                  })),
        ]);
  }

  Future<List> createList() async {
    apps = [
      {
        "name": 'Example',
        "subheading": 'Nothing special',
        "bg": 'example.jpg',
        "disabled": false,
        "webview": WebView(
          key: ValueKey('Example'),
          initialUrl: await createInitialLogin("https://example.staging.jimber.org"),
          javascriptMode: JavascriptMode.unrestricted,
        ),
        "callback": updateApp
      },
      {
        "name": 'FreeFlowPages',
        "subheading": 'Where privacy and social media co-exist.',
        "bg": 'ffp.jpg',
        "disabled": false,
        "webview": WebView(
          key: ValueKey('FreeFlowPages'),
          initialUrl: await createInitialLogin('https://staging.freeflowpages.com/user/auth/external?authclient=3bot'),
          javascriptMode: JavascriptMode.unrestricted,
        ),
        "callback": updateApp
      },
      {
        "name": 'OpenBrowser',
        "subheading": 'By Jimber',
        "url": 'https://broker.jimber.org',
        "bg": 'jimber.png',
        "disabled": false,
        "webview": WebView(
          key: ValueKey('OpenBrowser'),
          initialUrl: 'https://broker.jimber.org',
          javascriptMode: JavascriptMode.unrestricted,
        ),
        "callback": updateApp
      },
      {
        "name": 'OpenMeetings',
        "subheading": 'Coming soon',
        "bg": 'om.jpg',
        "disabled": true,
        "callback": updateApp
      }
    ];
    return apps;
  }
  void updateApp (app) {
    apps.firstWhere((a) => a['name'] == app['name'])['webview'] = app['webview'];
  }
  Future<String> createInitialLogin(url) async {
    String initialUrl = url;
    var union = '?';
    if (initialUrl.indexOf('?') > -1) union = '&';
    initialUrl += union + 'logintoken=' + _randomString(20);
    initialUrl += '&doublename=' + await getDoubleName();
    return initialUrl;
  }

  String _randomString(int length) {
    var rand = 'abc123';
    saveLoginToken(rand);
    return rand;
  }
}
