import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/fingerprintService.dart';
import 'package:threebotlogin/widgets/ImageButton.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/widgets/PreferenceDialog.dart';

class LoginScreen extends StatefulWidget {
  final Widget loginScreen;
  final Widget scopeList;
  final message;
  final bool closeWhenLoggedIn;

  LoginScreen(this.message,
      {Key key,
      this.loginScreen,
      this.closeWhenLoggedIn = false,
      this.scopeList})
      : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

Future<bool> _onWillPop() async {
  var index = 0;
  cancelLogin(await getDoubleName());
  for (var flutterWebViewPlugin in flutterWebViewPlugins) {
    if (flutterWebViewPlugin != null) {
      if (index == lastAppUsed) {
        flutterWebViewPlugin.show();
        showButton = true;
      }
      index++;
    }
  }
  return Future.value(true);
}

class _LoginScreenState extends State<LoginScreen> {
  String helperText = '';
  List<int> imageList = new List();
  var selectedImageId = -1;
  var correctImage = -1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var scope = Map();
  bool cancelBtnVisible = false;

  bool showPinfield = false;
  bool showScopeAndEmoji = false;

  bool _isAuthenticated;

  // PreferenceDialog scopeListc = new PreferenceDialog(scope, appId, callback);

  @override
  void initState() {
    super.initState();

    var generated = 1;
    var rng = new Random();
    if (isNumeric(widget.message['randomImageId'])) {
      correctImage = int.parse(widget.message['randomImageId']);
    } else {
      correctImage = 1;
    }

    imageList.add(correctImage);

    while (generated <= 3) {
      var x = rng.nextInt(266) + 1;
      if (!imageList.contains(x)) {
        imageList.add(x);
        generated++;
      }
    }

    isFingerPrintActive();

    setState(() {
      imageList.shuffle();
    });
  }

  isFingerPrintActive() {
    checkFingerPrintActive();
  }

  checkFingerPrintActive() async {
    bool isValue = await getFingerprint();

    if (isValue) {
      bool isAuthenticate = await authenticate();

      if (isAuthenticate) {
        // Show scopes + emmoji
        print('inside authenticate');
        return finishLogin();
      }
    }
    // Show Pinfield
    print('showing pinfield');
    setState(() {
      helperText = 'Enter your pincode to log in';
      showPinfield = true;
    });
  }

  finishLogin() async {
    // making scope
    scope['doubleName'] = await getDoubleName();
    print('widget ${widget.message['scope']}');
    if (widget.message['scope'] != null) {
      if (jsonDecode(widget.message['scope']).containsKey('email')) {
        scope['email'] = await getEmail();
      }

      if (jsonDecode(widget.message['scope']).containsKey('keys')) {
        scope['keys'] =
            await getKeys(widget.message['appId'], scope['doubleName']);
      }
    }
    print('scope $scope');
    cancelBtnVisible = true;

    setState(() {
      showScopeAndEmoji = true;
      showPinfield = false;
    });
  }

  Widget scopeEmojiView() {
    final List<String> entries = <String>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F'
    ];

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                  child: Text(
                    'Please select your preferred scopes and the asked emoji to continue',
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: SizedBox(
                  height: 200.0,
                  child: PreferenceDialog(
                    scope: scope,
                    appId: widget.message['appId'],
                    callback: cancelIt,
                    type: 'login',
                  )),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ImageButton(imageList[0], selectedImageId,
                            imageSelectedCallback),
                        ImageButton(imageList[1], selectedImageId,
                            imageSelectedCallback),
                        ImageButton(imageList[2], selectedImageId,
                            imageSelectedCallback),
                        ImageButton(imageList[3], selectedImageId,
                            imageSelectedCallback),
                      ])),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Login'),
          elevation: 0.0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Container(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Visibility(
                      visible: showPinfield,
                      child: Expanded(
                        flex: 2,
                        child: Center(child: Text(helperText)),
                      ),
                    ),
                    Visibility(
                      visible: showPinfield,
                      child: Expanded(
                        flex: 6,
                        child: showPinfield
                            ? PinField(callback: (p) => pinFilledIn(p))
                            : Container(),
                      ),
                    ),
                    Visibility(
                      visible: showScopeAndEmoji,
                      child: Expanded(
                        flex: 6,
                        child:
                            showScopeAndEmoji ? scopeEmojiView() : Container(),
                      ),
                    ),
                    Visibility(
                      visible: cancelBtnVisible,
                      child: Expanded(
                        flex: 0,
                        child: FlatButton(
                          child: Text(
                            "It wasn\'t me - cancel",
                            style: TextStyle(
                                fontSize: 14.0, color: Color(0xff0f296a)),
                          ),
                          onPressed: () {
                            cancelIt();
                            Navigator.of(context).pop();
                            _onWillPop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  imageSelectedCallback(imageId) {
    setState(() {
      selectedImageId = imageId;
    });

    if (selectedImageId != -1 || isMobile()) {
      if (isMobile() || selectedImageId == correctImage) {
        setState(() {
          print('send it again');
          sendIt();
        });
      } else {
        setState(() {
          print('send it again');
          sendIt();
        });
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text('Oops... that\'s the wrong emoji')));
      }
    } else {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Please select an emoji')));
    }
  }

  pinFilledIn(p) async {
    final pin = await getPin();
    if (pin == p) {
      print('Onto showing scopes and emojis');
      return finishLogin();
    } else {
      setState(() {
        print('send it again');
        sendIt();
      });
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Oops... you entered the wrong pin')));
    }
  }

  cancelIt() async {
    cancelLogin(await getDoubleName());
    Navigator.pushNamed(context, '/');
    var index = 0;

    for (var flutterWebViewPlugin in flutterWebViewPlugins) {
      if (flutterWebViewPlugin != null) {
        if (index == lastAppUsed) {
          flutterWebViewPlugin.show();
          showButton = true;
        }
        index++;
      }
    }
  }

  sendIt() async {
    print('sendIt');
    var state = widget.message['state'];

    var publicKey = widget.message['appPublicKey']?.replaceAll(" ", "+");
    bool hashMatch = RegExp(r"[^A-Za-z0-9]+").hasMatch(state);
    print("hash match?? " + hashMatch.toString() + " false is ok");
    if (hashMatch) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('States can only be alphanumeric [^A-Za-z0-9]'),
      ));
      // Navigator.popUntil(context, ModalRoute.withName('/'));
      // Navigator.pushNamed(context, '/success');
      return;
    }

    var signedHash = signData(state, await getPrivateKey());

    try {
      scope = await refineScope(scope);
    } catch (exception) {}

    var data = encrypt(jsonEncode(scope), publicKey, await getPrivateKey());

    sendData(state, await signedHash, await data, selectedImageId);
    if (selectedImageId == correctImage || isMobile() || _isAuthenticated) {
      if (widget.closeWhenLoggedIn) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        try {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          Navigator.pushNamed(context, '/success');
        } catch (e) {}
      }
    } else {
      setState(() {
        print('send it again');
        sendIt();
      });
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Oops... you selected the wrong emoji')));
    }
  }

  dynamic refineScope(scope) async {
    var json = jsonDecode(await getScopePermissions());
    var permissions = json[scope['keys']['appId']];
    var keysOfPermissions = permissions.keys.toList();

    keysOfPermissions.forEach((var value) {
      if (!permissions[value]['enabled']) {
        scope.remove(value);
      }
    });

    return scope;
  }

  bool isMobile() {
    var mobile = widget.message['mobile'];

    if (mobile is String) {
      return mobile == 'true';
    } else if (mobile is bool) {
      return mobile == true;
    }

    return false;
    // return (widget.message['mobile'] == 'true' || widget.message['mobile'] == true);
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
