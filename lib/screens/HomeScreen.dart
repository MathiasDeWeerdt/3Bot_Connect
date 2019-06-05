import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/firebaseService.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
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
  bool openPendingLoginAttemt = true;
  String doubleName = '';
  var email;
  AppSelector selector;

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
    selector = AppSelector();
    
    // testing();
  }

  Future testing() async {
    final url =
        'https://staging.freeflowpages.com/user/auth/external?authclient=3bot';
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

    logger.log(appid);
    logger.log(newRedirectUrl);
    logger.log(cookies);
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
      openPendingLoginAttemt = false;
    });

    if (link.host == 'register') {
      logger.log('Register via link');
      openPage(RegistrationWithoutScanScreen(
        link.queryParameters,
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void checkIfThereAreLoginAttempts(dn) async {
    if (await getPrivateKey() != null && deviceId != null) {
      checkLoginAttempts(dn).then((attempt) {
        logger.log('-----=====------');
        logger.log(deviceId);
        logger.log(attempt.body);
        if (attempt.body != '' && openPendingLoginAttemt)
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen(jsonDecode(attempt.body))));
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
        setState(() {
          doubleName = dn;
        });
      }
    } else if (response == 0) {
      Navigator.pushReplacementNamed(context, '/error');
    } else if (response == -1) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ErrorScreen(errorMessage: "Can't connect to server.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('3Bot'),
            leading: IconButton(
                tooltip: 'Apps',
                icon: const Icon(Icons.apps),
                onPressed: () {
                  flutterWebViewPlugins[1].hide();
                }),
            elevation: 0.0,
            actions: <Widget>[
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
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            selector = AppSelector();

                            return selector;
                          } else
                            return notRegistered(context);
                        }),
                  ),
                ))));
  }

  Column registered(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 42.0,
          color: Theme.of(context).accentColor,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text('Hi ' + (doubleName != null ? doubleName : '')),
        SizedBox(
          height: 12.0,
        ),
        Text('If you need to login you\'ll get a notification.'),
        SizedBox(
          height: 24.0,
        )
      ],
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
