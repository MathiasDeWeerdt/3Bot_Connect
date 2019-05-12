import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/widgets/scopeDialog.dart';

class LoginScreen extends StatefulWidget {
  final Widget loginScreen;
  final message;
  final bool closeWhenLoggedIn;
  // data: {appPublicKey: xKHlaIyza5dSxswOmvuYV7MDreIbLllK9T0n3c1tu0g=, appId: ExampleAppId, scope: ["user:email"], state: gk4NFmIrrEZiSjv6J0tl9mDBSZTP3Dah, doubleName: ol.d}}

  LoginScreen(this.message,
      {Key key, this.loginScreen, this.closeWhenLoggedIn = false})
      : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String helperText = 'Give in your pincode to log in';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    child: Container(
                        padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                  width: double.infinity,
                                  padding:
                                      EdgeInsets.only(top: 24.0, bottom: 24.0),
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

  pinFilledIn(p) async {
    print(widget.message);
    print('pinFilledIn');
    print(widget.message);
    print('initalBody');
    final pin = await getPin();
    print(pin);
    print(p);
    if (pin == p) {
      print('pin OK');
      if (widget.message != null && widget.message['scope'] != null) {
        print(widget.message['scope']);
        print(widget.message['scope'].split(","));
        showScopeDialog(context, widget.message['scope'].split(","), widget.message['appId'], sendIt);
      }
      else {
        sendIt();
      }
    } else {
      print('pin NOK');
      setState(() {
        helperText = "Pin code not ok";
      });
    }
  }

  sendIt() async {
    print('sendIt');
    var state = widget.message['state'];
    var publicKey = widget.message['appPublicKey'];
    var privateKey = getPrivateKey();
    var email = getEmail();

    var signedHash = signHash(state,  await privateKey);
    var scope = {};
    var data;
    if (widget.message['scope'] != null) {
      if (widget.message['scope'].split(",").contains('user:email')) scope['email'] = await email;
    }
    if (scope.isNotEmpty) {
      print(scope.isEmpty);
      data = await encrypt(jsonEncode(scope), publicKey, await privateKey);
    }
    sendData(state, await signedHash, data);

    if (widget.closeWhenLoggedIn) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/success',ModalRoute.withName('/'));
    }
  }
}
