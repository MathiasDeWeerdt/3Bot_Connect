import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/scopeDialog.dart';

class RegistrationWithoutScanScreen extends StatefulWidget {
  final Widget registrationWithoutScanScreen;
  final initialData;
  RegistrationWithoutScanScreen(this.initialData,
      {Key key, this.registrationWithoutScanScreen})
      : super(key: key);

  _RegistrationWithoutScanScreen createState() =>
      _RegistrationWithoutScanScreen();
}

class _RegistrationWithoutScanScreen
    extends State<RegistrationWithoutScanScreen> {
  String helperText = 'Choose new pin';
  String pin;
  @override
  void initState() {
    super.initState();
    getPrivateKey().then((pk) => pk != null
        ? _showDialog()
        : sendScannedFlag(widget.initialData['hash'], deviceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
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

  Future pinFilledIn(String value) async {
    if (pin == null) {
      setState(() {
        pin = value;
        helperText = 'Confirm pin';
      });
    } else if (pin != value) {
      setState(() {
        pin = null;
        helperText = 'Pins do not match, choose pin';
      });
    } else if (pin == value) {
    print(widget.initialData['scope']);
      print('pin OK');
      if (widget.initialData['scope'] != null) {
        showScopeDialog(context, widget.initialData['scope'].split(","),
            widget.initialData['appId'], sendIt);
      } else {
        sendIt();
      }
    }
  }

  sendIt() async {
    var hash = widget.initialData['hash'];
    var privateKey = widget.initialData['privateKey'];
    var doubleName = widget.initialData['doubleName'];
    var email = widget.initialData['email'];
    var publicKey = widget.initialData['appPublicKey'];

    savePin(pin);
    savePrivateKey(privateKey);
    saveEmail(email, false);
    saveDoubleName(doubleName);

    var signedHash = signHash(hash, privateKey);
    var scope = {};
    var data;
    if (widget.initialData['scope'] != null) {
      if (widget.initialData['scope'].split(",").contains('user:email')) scope['email'] = await getEmail();
    }
    if (scope.isNotEmpty) {
      print(scope.isEmpty);
      data = await encrypt(jsonEncode(scope), publicKey, privateKey);
    }
    sendData(hash, await signedHash, data);

    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.of(context).pushNamed('/success');
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("You are about to register a new account"),
          content: new Text(
              "If you continue, you won't be abel to login with the current account again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            FlatButton(
              child: new Text("Continue"),
              onPressed: () {
                Navigator.pop(context);
                clearData();
                sendScannedFlag(widget.initialData['hash'], deviceId);
              },
            ),
          ],
        );
      },
    );
  }
}
