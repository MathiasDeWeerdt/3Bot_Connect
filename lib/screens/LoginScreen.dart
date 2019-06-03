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

  LoginScreen(this.message, {Key key, this.loginScreen, this.closeWhenLoggedIn=false}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String helperText = 'Give in your pincode to log in';
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
    if (isNumeric(widget.message['randomImageId']))
      correctImage = int.parse(widget.message['randomImageId']);
    else
      correctImage = 1;

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
    return Scaffold(
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
                            topRight: Radius.circular(20.0))),
                    child: SingleChildScrollView(
                        child: Container(
                      padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
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
                              ]),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 24.0, bottom: 24.0),
                              child: Center(
                                  child: Text(
                                helperText,
                                style: TextStyle(fontSize: 16.0),
                              ))),
                          PinField(callback: (p) => pinFilledIn(p))
                        ],
                      ),
                    ))))));
  }

  imageSelectedCallback(imageId) {
    setState(() {
      selectedImageId = imageId;
    });
  }

  pinFilledIn(p) async {
    if (selectedImageId != -1) {
      final pin = await getPin();
      if (pin == p) {
        scope['doubleName'] = widget.message['doubleName'];
        if (widget.message['scope'].contains('user:email'))
          scope['email'] = await getEmail();
        showScopeDialog(context, scope, widget.message['appId'], sendIt);

      } else {
         _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Oops... you entered the wrong pin'),
        ));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Please select an emoji'),
      ));
    }
  }

  sendIt() async {
    print('sendIt');
    var state = widget.message['state'];
    var publicKey = widget.message['appPublicKey']?.replaceAll(" ", "+");

    var signedHash = signHash(state, await getPrivateKey());
    var data = encrypt(jsonEncode(scope), publicKey, await getPrivateKey());

    sendData(state, await signedHash, await data, selectedImageId);
    if (selectedImageId == correctImage) {
      if (widget.closeWhenLoggedIn) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        Navigator.of(context).pushNamed('/success');
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Oops... you selected the wrong emoji'),
      ));
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
