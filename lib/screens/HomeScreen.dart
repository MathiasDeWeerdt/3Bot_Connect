import 'dart:async';
import 'dart:io';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/screens/LoginScreen.dart';
import 'package:threebotlogin/screens/MobileRegistrationScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/firebaseService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/BottomNavbar.dart';
import 'package:threebotlogin/widgets/PreferenceWidget.dart';
import 'package:uni_links/uni_links.dart';
import 'ErrorScreen.dart';
import 'RegistrationWithoutScanScreen.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'dart:convert';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final Widget homeScreen;

  HomeScreen({Key key, this.homeScreen}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool openPendingLoginAttempt = true;
  String doubleName = '';
  var email;
  String initialLink = null;
  int selectedIndex = 0;
  int ffpUrlIndex;
  AppBar appBar;
  BottomNavBar bottomNavBar;
  BuildContext bodyContext;
  Size preferredSize;
  bool isLoading = false;

  final navbarKey = new GlobalKey<BottomNavBarState>();
  bool showSettings = false;
  bool showPreference = false;

  @override
  void initState() {
    getEmail().then((e) {
      setState(() {
        email = e;
      });
    });

    if (initialLink == null) {
      getLinksStream().listen((String incomingLink) {
        logger.log('Got initial link from stream: ' + incomingLink);
        checkWhatPageToOpen(Uri.parse(incomingLink));
      });
    }

    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        print(visible);

        webViewResizer(visible);
      },
    );
    WidgetsBinding.instance.addObserver(this);
    onActivate(true);
  }

  Future<void> webViewResizer(keyboardUp) async {
    double keyboardSize;
    var size = MediaQuery.of(context).size;
    print(MediaQuery.of(context).size.height.toString() + " size of screen");
    var appKeyboard = flutterWebViewPlugins[keyboardUsedApp];
    print(appKeyboard);
    print(appKeyboard.webview);

    Future.delayed(
        Duration(milliseconds: 150),
        () => {
              if (keyboardUp)
                {
                  keyboardSize = MediaQuery.of(context).viewInsets.bottom,
                  flutterWebViewPlugins[keyboardUsedApp].resize(
                      Rect.fromLTWH(
                          0, 75, size.width, size.height - keyboardSize - 75),
                      instance: appKeyboard.webview),
                  print(keyboardSize.toString() + " size keyboard at opening"),
                  print('inside true keyboard')
                }
              else
                {
                  keyboardSize = MediaQuery.of(context).viewInsets.bottom,
                  flutterWebViewPlugins[keyboardUsedApp].resize(
                      Rect.fromLTWH(0, 75, size.width, size.height - 75),
                      instance: appKeyboard.webview),
                  print(keyboardSize.toString() + " size keyboard at closing"),
                  print('inside false keyboard')
                }
            });
  }

  Future<Null> initUniLinks() async {
    initialLink = await getInitialLink();

    if (initialLink != null) {
      logger.log('Found initialLink: ' + initialLink);
      checkWhatPageToOpen(Uri.parse(initialLink));
    }
  }

  checkWhatPageToOpen(Uri link) async {
    if (link.host == 'register') {
      logger.log('Register via link');
      openPage(RegistrationWithoutScanScreen(
        link.queryParameters,
        resetPin: false,
      ));
    } else if (link.host == "registeraccount") {
      logger.log('registeraccount HERE: ' + link.queryParameters['doubleName']);

      // Check if we already have an account registered before showing this screen.
      String doubleName = await getDoubleName();
      String privateKey = await getPrivateKey();

      if (doubleName == null || privateKey == null) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MobileRegistrationScreen(
                    doubleName: link.queryParameters['doubleName'])));
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.check,
            title: "You're already logged in",
            description: new Text(
                "We cannot create a new account, you already have an account registered on your device. Please restart the application if this message persists."),
            actions: <Widget>[
              FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      }
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
        logger.log("Checking if there are login attempts.");
        try {
          if (attempt.body != '' && openPendingLoginAttempt) {
            logger.log("Found a login attempt, opening ...");

            String name = ModalRoute.of(context).settings.name;

            // Navigator.popUntil(context, ModalRoute.withName('/'));

            Navigator.popUntil(context, (route) {
              if (route.settings.name == "/") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(jsonDecode(attempt.body),
                        closeWhenLoggedIn: true),
                  ),
                );
              }
              return true;
            });
          } else {
            logger.log("We currently have no open login attempts.");
          }
        } catch (exception) {
          logger.log(exception);
        }
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

      String dn = await getDoubleName();

      String tmpDoubleName = await getDoubleName();

      // Check if the user didn't click the notification.

      checkIfThereAreLoginAttempts(tmpDoubleName);
      await initUniLinks();

      if (tmpDoubleName != null) {
        var sei = await getSignedEmailIdentifier();
        var email = await getEmail();

        logger.log("sei: " + sei.toString());

        if (sei != null &&
            sei.isNotEmpty &&
            email["email"] != null &&
            email["verified"]) {
          logger.log(
              "Email is verified and we have a signed email to verify this verification to a third party");

          logger.log("Email: ", email["email"]);
          logger.log("Verification status: ", email["verified"].toString());
          logger.log("Signed email: ", sei);

          // We could recheck the signed email here, but this seems to be overkill, since its already verified.
        } else {
          logger.log(
              "We are missing email information or have not been verified yet, attempting to retrieve data ...");

          logger.log("Email: ", email["email"]);
          logger.log("Verification status: ", email["verified"].toString());
          logger.log("Signed email: ", sei.toString());

          logger.log("Getting signed email from openkyc.");
          getSignedEmailIdentifierFromOpenKYC(tmpDoubleName)
              .then((response) async {
            if (response.statusCode == 404) {
              logger.log(
                  "Can't retrieve signedEmailidentifier, we need to resend email verification.");
              logger.log("Response: " + response.body);
              return;
            }

            var body = jsonDecode(response.body);
            var signedEmailIdentifier = body["signed_email_identifier"];

            if (signedEmailIdentifier != null &&
                signedEmailIdentifier.isNotEmpty) {
              logger.log(
                  "Received signedEmailIdentifier: " + signedEmailIdentifier);

              var vsei = json.decode(
                  (await verifySignedEmailIdentifier(signedEmailIdentifier))
                      .body);

              if (vsei != null &&
                  vsei["email"] == email["email"] &&
                  vsei["identifier"].toLowerCase() ==
                      tmpDoubleName.toLowerCase()) {
                logger.log(
                    "Verified signedEmailIdentifier authenticity, saving data.");
                await saveEmail(vsei["email"], true);
                await saveSignedEmailIdentifier(signedEmailIdentifier);
              } else {
                logger.log(
                    "Couldn't verify authenticity, saving unverified email.");
                await saveEmail(email["email"], false);
                await removeSignedEmailIdentifier();
              }
            } else {
              logger.log(
                  "No valid signed email has been found, please redo the verification process.");
            }
          });
        }

        if (mounted) {
          setState(() {
            doubleName = tmpDoubleName;
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
    appBar = AppBar(
      backgroundColor: hexColor,
      elevation: 0.0,
    );

    bottomNavBar = BottomNavBar(
      key: navbarKey,
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
    );

    return Scaffold(
      appBar: PreferredSize(child: appBar, preferredSize: Size.fromHeight(20)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
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
                    return registered(context);
                  } else {
                    return notRegistered(context);
                  }
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FutureBuilder(
        future: getDoubleName(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return bottomNavBar;
          } else {
            return new Container(width: 0.0, height: 0.0);
          }
        },
      ),
      floatingActionButton: showSettings == true
          ? FloatingActionButton(
              onPressed: () {
                logger.log("Pressed!");
                setState(() {
                  showPreference = true;
                });
              },
              child: Icon(Icons.settings),
            )
          : null,
    );
  }

  void onItemTapped(int index) {
    setState(() {
      for (var flutterWebViewPlugin in flutterWebViewPlugins) {
        if (flutterWebViewPlugin != null) {
          flutterWebViewPlugin.hide();
        }
      }
      ffpUrlIndex = null;
      selectedIndex = index;
      logger.log("Index: ", index);
      if (index == 4) {
        showSettings = true;
      } else {
        showSettings = false;
        showPreference = false;
      }
    });
    updateApp(apps[index]);
  }

  Widget registered(BuildContext context) {
    bodyContext = context;

    var comingSoonWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Coming soon'),
        SizedBox(
          height: 20,
        ),
      ],
    );

    switch (selectedIndex) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/3bot_bot.png',
              height: 100.0,
            ),
            Padding(
                padding: EdgeInsets.only(top: 15, bottom: 5),
                child: Text(
                  "Welcome to the first version of your 3Bot.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
            Text("More functionality will be added soon.",
                style: TextStyle(fontSize: 18)),
            SizedBox(
              height: 200,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: new EdgeInsets.all(10.0),
                child: Text("Your Circles",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      onPressed: () => openFfp(0),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF Tokens"),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.greenAccent,
                      elevation: 0,
                      onPressed: () => openFfp(1),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF Grid"),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.blueAccent,
                      elevation: 0,
                      onPressed: () => openFfp(2),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF Farmers"),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.grey,
                      elevation: 0,
                      onPressed: () => openFfp(3),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("FF Nation"),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.orangeAccent,
                      elevation: 0,
                      onPressed: () => openFfp(4),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("3Bot"),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {},
                  child: new Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.green,
                  padding: const EdgeInsets.all(1.0),
                )
              ],
            ),
          ],
        );
      case 2:
        return comingSoonWidget;
      case 4:
        return showPreference ? PreferenceWidget() : Text("");
      default:
        return isLoading
            ? Center(child: CircularProgressIndicator())
            : comingSoonWidget;
    }
  }

  void openFfp(int urlIndex) async {
    setState(() {
      selectedIndex = 3;
      ffpUrlIndex = urlIndex;
    });
    if (preferredSize == null) {
      preferredSize = preferredSize = getPreferredSizeForWebview();
    }
    if (flutterWebViewPlugins[apps[3]['id']] != null) {
      await flutterWebViewPlugins[apps[3]['id']].close();
      flutterWebViewPlugins[apps[3]['id']] = null;
    }

    logger.log("Webview was not null but another ffp link was clicked on");
    await launchApp(preferredSize, apps[3]['id']);

    logger.log("Webviews is showing ffp link");
    flutterWebViewPlugins[apps[3]['id']].show();
  }

  ConstrainedBox notRegistered(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          maxHeight: double.infinity,
          maxWidth: double.infinity,
          minHeight: 250,
          minWidth: 250),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
          Image.asset(
            'assets/logo.png',
            height: 100.0,
          ),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Welcome to 3Bot connect.',
                    style: TextStyle(fontSize: 24)),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30),
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Icon(
                        CommunityMaterialIcons.account_edit,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'Register Now!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration');
                  },
                ),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30),
                  ),
                  color: Theme.of(context).accentColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Icon(
                        CommunityMaterialIcons.backup_restore,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'Recover account',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/recover');
                  },
                ),
              ],
            ),
          ),
          Container(),
        ],
      ),
    );
  }

  Size getBottomNavbarHeight() {
    //returns null:
    final State state = navbarKey.currentState;

    //Error: The getter 'context' was called on null.
    final RenderBox box = state.context.findRenderObject();

    return box.size;
  }

  Size getPreferredSizeForWebview() {
    var contextSize = MediaQuery.of(bodyContext).size;

    // preferredHeight is the height of our screen minus the top navbar height and minus the bottom navbar height
    var preferredHeight = contextSize.height -
        appBar.preferredSize.height -
        getBottomNavbarHeight().height;
    var preferredWidth = contextSize.width;

    return new Size(preferredWidth, preferredHeight);
  }

  Future<void> updateApp(app) async {
    if (!app['disabled']) {
      final emailVer = await getEmail();
      // If email is verified or wallet app is selected, continue
      if (emailVer['verified'] || selectedIndex == 1) {
        if (!app['errorText']) {
          final prefs = await SharedPreferences.getInstance();

          preferredSize = getPreferredSizeForWebview();

          if (!prefs.containsKey('firstvalidation')) {
            logger.log(app['url']);
            logger.log("launching app " + app['id'].toString());
            launchApp(preferredSize, app['id']);

            prefs.setBool('firstvalidation', true);
          }

          showButton = true;
          lastAppUsed = app['id'];
          keyboardUsedApp = app['id'];
          print("keyboardapp open: " + keyboardUsedApp.toString());
          if (flutterWebViewPlugins[app['id']] == null) {
            await launchApp(preferredSize, app['id']);
            logger.log("Webviews was null");
          }
          // The launch can change the webview to null if permissions weren't granted
          if (flutterWebViewPlugins[app['id']] != null) {
            logger.log("Webviews is showing");
            flutterWebViewPlugins[app['id']].show();
          }
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
    }
  }

  Future<void> launchApp(size, appId) async {
    this.setState(() => {isLoading = true});
    if (flutterWebViewPlugins[appId] == null) {
      flutterWebViewPlugins[appId] = new FlutterWebviewPlugin();
    }
    try {
      var url = apps[appId]['cookieUrl'];
      var loadUrl = apps[appId]['url'];

      var localStorageKeys = apps[appId]['localStorageKeys'];

      var cookies = '';
      final union = '?';
      if (url != '') {
        if (ffpUrlIndex != null) {
          url = apps[appId]['ffpUrls'][ffpUrlIndex];
        }
        final client = http.Client();
        var request = new http.Request('GET', Uri.parse(url))
          ..followRedirects = false;
        var response = await client.send(request);

        if (response.statusCode == 401) {
          url = apps[appId]['cookieUrl'];
          request = new http.Request('GET', Uri.parse(url))
            ..followRedirects = false;
          response = await client.send(request);
        }

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

        if (scope != null && scope.contains("\"email\":")) {
          scopeData['email'] = await getEmail();
          print("adding scope");
        }

        var jsonData = jsonEncode(
            (await encrypt(jsonEncode(scopeData), publickey, privateKey)));
        var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();
        loadUrl =
            'https://$appName$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeComponent(await signedHash)}&data=$data';

        logger.log("!!!loadUrl: " + loadUrl);
        var cookieList = List<Cookie>();
        cookieList.add(Cookie.fromSetCookieValue(cookies));

        flutterWebViewPlugins[appId]
            .launch(loadUrl,
                rect: Rect.fromLTWH(
                    0.0, appBar.preferredSize.height, size.width, size.height),
                userAgent: kAndroidUserAgent,
                hidden: true,
                cookies: cookieList,
                withLocalStorage: true,
                permissions: new List<String>.from(apps[appId]['permissions']))
            .then((permissionGranted) {
          if (!permissionGranted) {
            showPermissionsNeeded(context, appId);
          }
        });
      } else if (localStorageKeys != null) {
        await flutterWebViewPlugins[appId]
            .launch(loadUrl + '/error',
                rect: Rect.fromLTWH(
                    0.0, appBar.preferredSize.height, size.width, size.height),
                userAgent: kAndroidUserAgent,
                hidden: true,
                cookies: [],
                withLocalStorage: true,
                permissions: new List<String>.from(apps[appId]['permissions']))
            .then((permissionGranted) {
          if (!permissionGranted) {
            showPermissionsNeeded(context, appId);
          }
        });

        var keys = await generateKeyPair();

        final state = randomString(15);

        final privateKey = await getPrivateKey();
        final signedHash = await signData(state, privateKey);

        var jsToExecute =
            "(function() { try {window.localStorage.setItem('tempKeys', \'{\"privateKey\": \"${keys["privateKey"]}\", \"publicKey\": \"${keys["publicKey"]}\"}\');  window.localStorage.setItem('state', '$state'); } catch (err) { return err; } })();";

        // This should be removed in the future!
        sleep(const Duration(seconds: 1));

        final res =
            await flutterWebViewPlugins[appId].evalJavascript(jsToExecute);
        final appid = apps[appId]['appid'];
        final redirecturl = apps[appId]['redirecturl'];
        var scope = {};
        scope['doubleName'] = await getDoubleName();
        scope['derivedSeed'] = await getDerivedSeed(appid);

        var encrypted =
            await encrypt(jsonEncode(scope), keys["publicKey"], privateKey);
        var jsonData = jsonEncode(encrypted);
        var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();

        loadUrl =
            'https://$appid$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(signedHash)}&data=$data';

        logger.log("!!!loadUrl: " + loadUrl);

        flutterWebViewPlugins[appId].reloadUrl(loadUrl);
        print("Eval result: $res");

        logger.log("Launching App" + [appId].toString());
      } else {
        flutterWebViewPlugins[appId]
            .launch(loadUrl,
                rect: Rect.fromLTWH(0.0, 75, size.width, size.height - 75),
                userAgent: kAndroidUserAgent,
                hidden: true,
                cookies: [],
                withLocalStorage: true,
                permissions: new List<String>.from(apps[appId]['permissions']))
            .then((permissionGranted) {
          if (!permissionGranted) {
            showPermissionsNeeded(context, appId);
          }
        });
        logger.log("Launching App" + [appId].toString());
      }

      logger.log(loadUrl);
      logger.log(cookies);

      flutterWebViewPlugins[appId].onStateChanged.listen((viewData) async {
        if (viewData.type == WebViewState.finishLoad) {
          print('done loading.....');
          this.setState(() => {isLoading = false});
        }
      });
    } on NoSuchMethodError catch (exception) {
      logger.log('error caught: $exception');
      apps[appId]['errorText'] = true;
    }
  }

  void showPermissionsNeeded(BuildContext context, appId) {
    flutterWebViewPlugins[appId].close();
    flutterWebViewPlugins[appId] = null;

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Need permissions",
        description: Container(
          child: Text(
            "Some ungranted permissions are needed to run this.",
            textAlign: TextAlign.center,
          ),
        ), //TODO: if iOS -> place link to settings
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
        title: "Email has been resent.",
        description: new Text("A new verification email has been sent."),
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
}
