import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/ImageButton.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/widgets/scopeDialog.dart';

class LoginScreen extends StatefulWidget {
  final Widget loginScreen;
  final message;
  final bool closeWhenLoggedIn;

  LoginScreen(this.message,
      {Key key, this.loginScreen, this.closeWhenLoggedIn = false})
      : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

Future<bool> _onWillPop() {
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
  return Future.value(true);
}

class _LoginScreenState extends State<LoginScreen> {
  String helperText = 'Enter your pincode to log in';
  List<int> imageList = new List();
  var selectedImageId = -1;
  var correctImage = -1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var scope = Map();

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
    setState(() {
      imageList.shuffle();
    });
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
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          !isMobile()
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                      ImageButton(imageList[0], selectedImageId,
                                          imageSelectedCallback),
                                      ImageButton(imageList[1], selectedImageId,
                                          imageSelectedCallback),
                                      ImageButton(imageList[2], selectedImageId,
                                          imageSelectedCallback),
                                      ImageButton(imageList[3], selectedImageId,
                                          imageSelectedCallback),
                                    ])
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                              child: Center(
                                  child: Text(
                                helperText,
                                style: TextStyle(fontSize: 16.0),
                              ))),
                          PinField(callback: (p) => pinFilledIn(p)),
                          FlatButton(
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
                        ],
                      ),
                    ),
                  ),
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
  }

  pinFilledIn(p) async {
    if (selectedImageId != -1 || isMobile()) {
      final pin = await getPin();
      if (pin == p) {
        scope['doubleName'] = await getDoubleName();
        if (widget.message['scope'] != null) {
          if (widget.message['scope'].contains('user:email')) {
            scope['email'] = await getEmail();
          }

          if (widget.message['scope'].contains('user:keys')) {
            scope['keys'] =
                await getKeys(widget.message['appId'], scope['doubleName']);
          }
        }
        if (selectedImageId == correctImage) {
          showScopeDialog(context, scope, widget.message['appId'], sendIt,
              cancelCallback: cancelIt);
        } else {
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text('Oops... that\'s the wrong emoji')));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text('Oops... you entered the wrong pin')));
      }
    } else {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Please select an emoji')));
    }
  }

  cancelIt() async {
    cancelLogin(await getDoubleName());
    print("inside cancelIt");
    Navigator.pushNamed(context, '/');
    print(lastAppUsed);
    logger.log('LASTAPPUSED ${lastAppUsed}');
    var index = 0;

    for (var flutterWebViewPlugin in flutterWebViewPlugins) {
      if (flutterWebViewPlugin != null) {
        if (index == lastAppUsed) {
          logger.log('LASTAPPUSED ${lastAppUsed}');
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
    var data = encrypt(jsonEncode(scope), publicKey, await getPrivateKey());

    sendData(state, await signedHash, await data, selectedImageId);
    if (selectedImageId == correctImage || isMobile()) {
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
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Oops... you selected the wrong emoji')));
    }
  }

  bool isMobile() {
    return (widget.message['mobile'] == 'true' || widget.message['mobile']);
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
