import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomWebview.dart';
import 'package:threebotlogin/widgets/SingleApp.dart';
import 'package:threebotlogin/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppSelector extends StatefulWidget {
  // AppSelector({Key key}) : super(key: key);

  _AppSelectorState instance = _AppSelectorState();

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
  String kAndroidUserAgent = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
     flutterWebViewPlugins[0] = new FlutterWebviewPlugin();
     flutterWebViewPlugins[1] = new FlutterWebviewPlugin();
     flutterWebViewPlugins[2] = new FlutterWebviewPlugin();
     flutterWebViewPlugins[3] = new FlutterWebviewPlugin();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // createInitialLogin('https://freeflowpages.com/user/auth/external?authclient=3bot').then((url) {
    //   flutterWebViewPlugins[1].launch(url,
    //     rect: Rect.fromLTWH(0.0, 75, size.width, size.height),
    //     userAgent: kAndroidUserAgent,
    //     hidden: true);

    //     flutterWebViewPlugins[1].onUrlChanged.listen((String url) {
    //       print("CHANGED: " + url);
    //     });
    // });

    flutterWebViewPlugins[1].launch("https://freeflowpages.com",
        rect: Rect.fromLTWH(0.0, 75, size.width, size.height),
         userAgent: kAndroidUserAgent,
        hidden: true);

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
        "initialUrl":
            'https://freeflowpages.com/',
        "callback": updateApp,
        "visible": false,
        "id": 1
      },
      {
        "name": 'OpenBrowser',
        "subheading": 'By Jimber',
        "url": 'https://broker.jimber.org',
        "bg": 'jimber.png',
        "disabled": false,
        "initialUrl": 'https://broker.jimber.org',
        "callback": updateApp,
        "visible": false,
        "id": 2
      }
      // {
      //   "name": 'OpenMeetings',
      //   "subheading": 'Coming soon',
      //   "bg": 'om.jpg',
      //   "disabled": true,
      //   "initialUrl": 'https://google.be',
      //   "callback": updateApp,
      //   "visible": false,
      //   "id": 3
      // }
    ];
    return apps;
  }


  void appsCallback() {
    // print("Has been called!");
    // flutterWebViewPlugins[0].hide();
  }

  void updateApp(app) {
    // if(!hasBeenInitialized) {
    //   flutterWebViewPlugins[0] = new FlutterWebviewPlugin();
    //   flutterWebViewPlugins[0].launch(app['initialUrl'],
    //   rect:
    //       Rect.fromLTWH(0.0, 100, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 100),
    //   userAgent: kAndroidUserAgent);
    //   hasBeenInitialized = true;
    // }
    final size = MediaQuery.of(context).size;

    if(app['id'] == 1) {
      // if(!hasFFPBeenInitialized) {
      //   flutterWebViewPlugins[1].launch("https://freeflowpages.com/user/auth/external?authclient=3bot",
      //       rect: Rect.fromLTWH(0.0, 100, size.width, size.height),
      //       userAgent: kAndroidUserAgent,
      //       hidden: true);
      //    hasFFPBeenInitialized = true;
      // }
    } else if(app['id'] == 2) {
        if(!hasBrowserBeenInitialized) {
            flutterWebViewPlugins[2].launch("https://broker.jimber.org",
                rect: Rect.fromLTWH(0.0, 75, size.width, size.height),
                userAgent: kAndroidUserAgent,
                hidden: true);
          hasBrowserBeenInitialized = true;
        }
    }

    flutterWebViewPlugins[app['id']].show();
  }

  Future<String> createInitialLogin(url) async {
    String initialUrl = url;
    var union = '?';
    if (initialUrl.indexOf('?') > -1) union = '&';
    initialUrl += union + 'logintoken=' + _randomString(20);
    initialUrl += '&doublename=' + await getDoubleName();

    logger.log(initialUrl);
    return initialUrl;
  }

  String _randomString(int length) {
    var rand = 'abc123';
    saveLoginToken(rand);
    return rand;
  }
}