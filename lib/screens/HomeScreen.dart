import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/firebaseService.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/AppSelector.dart';
import 'package:uni_links/uni_links.dart';
import 'ErrorScreen.dart';
import 'RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final Widget homeScreen;

  HomeScreen({Key key, this.homeScreen}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool openPendingLoginAttempt = true;
  String doubleName = '';
  var email;
  Color hexColor = Color(0xff0f296a);

  @override
  void initState() {
    getEmail().then((e) {
      setState(() {
        email = e;
      });
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onActivate(true);
  }

  refresh(colorData) {
    setState(() {
      this.hexColor = Color(colorData);
    });
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
    setState(() {
      openPendingLoginAttempt = false;
    });

    if (link.host == 'register') {
      logger.log('Register via link');
      openPage(RegistrationWithoutScanScreen(
        link.queryParameters,
        resetPin: false,
      ));
    } else if (link.host == 'login') {
      logger.log('Login via link');
      openPage(LoginScreen(
        link.queryParameters,
        closeWhenLoggedIn: true,
      ));
    }
    logger.log('==============');
  }

  openPage(page) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void checkIfThereAreLoginAttempts(dn) async {
    if (await getPrivateKey() != null && deviceId != null) {
      checkLoginAttempts(dn).then((attempt) {
        logger.log("attempt: ");
        logger.log(attempt);
        logger.log('-----=====------');
        logger.log(deviceId);
        logger.log(attempt.body);
        try {
          logger.log("Inside the try");
          if (attempt.body != '' && openPendingLoginAttempt) {
            logger.log("We passed the IF!");
            Navigator.popUntil(context, ModalRoute.withName('/'));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                      jsonDecode(attempt.body),
                    ),
              ),
            );
          }
        } catch (exception) {
          logger.log("We caught the exception!");
          logger.log(exception);
        }

        logger.log('-----=====------');
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onActivate(false);
    }
  }

  Future onActivate(bool initFirebase) async {
    var buildNr = (await PackageInfo.fromPlatform()).buildNumber;
    logger.log('Current buildnumber: ' + buildNr);

    int response = await checkVersionNumber(context, buildNr);

    if (response == 1) {
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
              logger.log(newEmailMap.body);
              var body = jsonDecode(newEmailMap.body);
              saveEmailVerified(body['verified'] == 1);
            });
          }
        });
        if (mounted) {
          setState(() {
            doubleName = dn;
          });
        }
      }
    } else if (response == 0) {
      Navigator.pushReplacementNamed(context, '/error');
    } else if (response == -1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ErrorScreen(errorMessage: "Can't connect to server."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3bot'),
        backgroundColor: hexColor,
        leading: FutureBuilder(
            future: getDoubleName(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                    tooltip: 'Apps',
                    icon: const Icon(Icons.apps),
                    onPressed: () {
                      for (var flutterWebViewPlugin in flutterWebViewPlugins) {
                        if (flutterWebViewPlugin != null) {
                          flutterWebViewPlugin.hide();
                        }
                      }
                      setState(() {
                        hexColor = Color(0xFF0f296a);
                      });
                    });
              } else
                return Container();
            }),
        elevation: 0.0,
        actions: <Widget>[
          FutureBuilder(
              future: getDoubleName(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return IconButton(
                    icon: Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      for (var flutterWebViewPlugin in flutterWebViewPlugins) {
                        if (flutterWebViewPlugin != null) {
                          flutterWebViewPlugin.hide();
                        }
                      }
                      setState(() {
                        hexColor = Color(0xFF0f296a);
                      });

                      Navigator.pushNamed(context, '/preference');
                    },
                  );
                } else
                  return Container();
              }),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
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
                      print(doubleName);
                      return registered(context);
                    } else {
                      print(doubleName);
                      return notRegistered(context);
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Column registered(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[AppSelector(notifyParent: refresh)],
    );
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
            "Scan QR code",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pushNamed(context, '/scan');
          },
        ),
        RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10)),
          padding: EdgeInsets.all(12),
          child: Text(
            "Recover Account",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pushNamed(context, '/recover');
          },
        )
      ],
    );
  }
}
