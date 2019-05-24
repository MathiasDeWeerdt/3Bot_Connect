import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/firebaseService.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/AppSelector.dart';
import 'package:uni_links/uni_links.dart';
import 'RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final Widget homeScreen;

  HomeScreen({Key key, this.homeScreen}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool openPendingLoginAttemt = true;
  String doubleName = '';
  AppSelector selector;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onActivate(true);
    selector = AppSelector();

    
  }

  Future<Null> initUniLinks() async {
    String initialLink = await getInitialLink();
    if (initialLink != null) {
      checkWhatPageToOpen(Uri.parse(initialLink));
    } else {
      getLinksStream().listen((String incomingLink) {
        checkWhatPageToOpen(Uri.parse(incomingLink));
      });
    }
  }

  checkWhatPageToOpen(Uri link) {
    print(link.queryParameters);
    setState(() {
      openPendingLoginAttemt = false;
    });
    if (link.host == 'register') {
      print('Register via link');
      openPage(RegistrationWithoutScanScreen(
        link.queryParameters,
      ));
    } else if (link.host == 'login') {
      print('Login via link');
      openPage(LoginScreen(
        link.queryParameters,
        closeWhenLoggedIn: true,
      ));
    }
  }

  openPage(page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void checkIfThereAreLoginAttempts(dn) async {
    if (await getPrivateKey() != null && deviceId != null) {
      checkLoginAttempts(dn).then((attempt) {
        print('-----=====------');
        print(deviceId);
        print(attempt.body);
        if (attempt.body != '' && openPendingLoginAttemt)
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen(jsonDecode(attempt.body))));
        print('-----=====------');
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.resumed) {
      onActivate(false);
    }
  }

  Future onActivate(bool initFirebase) async {
    var buildNr = (await PackageInfo.fromPlatform()).buildNumber;
    print('Current buildnr is ' + buildNr);
    if (await checkVersionNumber(buildNr)) {
      if (initFirebase) {
        initFirebaseMessagingListener(context);
      }
      initUniLinks();
      String dn = await getDoubleName();
      checkIfThereAreLoginAttempts(dn);
      if (dn != null || dn != '') {
        getEmail().then((emailMap) async {
          if (emailMap['verified'] != null && !emailMap['verified']) {
            checkVerificationStatus(dn).then((newEmailMap) async {
              print(newEmailMap.body);
              var body = jsonDecode(newEmailMap.body);
              saveEmailVerified(body['verified'] == 1);
            });
          }
        });
        setState(() {
          doubleName = dn;
        });
      }
    } else {
      Navigator.pushReplacementNamed(context, '/error');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('3Bot'), leading: IconButton(
            tooltip: 'Apps',
            icon: const Icon(Icons.apps),
            onPressed: () {
              flutterWebViewPlugins[0].hide();
              flutterWebViewPlugins[1].hide();
              flutterWebViewPlugins[2].hide();
              flutterWebViewPlugins[3].hide();
              // selector.showMenu();
            }), elevation: 0.0, actions: <Widget>[
          FutureBuilder(
              future: getDoubleName(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return IconButton(
                    icon: Icon(Icons.person),
                    tooltip: 'Your profile',
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  );
                } else
                  return Container();
              }),
        ]),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
                child: Container(
                    child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  child: FutureBuilder(
                      future: getDoubleName(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          selector = AppSelector();

                          return selector;
                        } else
                          return notRegistered(context);
                      }),
                )))));
  }



  Column notRegistered(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('You are not registered yet.'),
        SizedBox(
          height: 20,
        ),
        RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10)),
          padding: EdgeInsets.all(12),
          child: Text(
            "Register now",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pushNamed(context, '/scan');
          },
        )
      ],
    );
  }
}
