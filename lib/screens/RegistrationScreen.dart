import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/PreferenceDialog.dart';
import 'package:threebotlogin/widgets/Scanner.dart';

class RegistrationScreen extends StatefulWidget {
  final Widget registrationScreen;
  RegistrationScreen({Key key, this.registrationScreen}) : super(key: key);
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  String helperText = "In order to finish registration, scan QR code";
  AnimationController sliderAnimationController;
  Animation<double> offset;
  dynamic qrData = '';
  String pin;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var scope = Map();

  @override
  void initState() {
    super.initState();
    sliderAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    sliderAnimationController.addListener(() {
      this.setState(() {});
    });

    offset = Tween<double>(begin: 0.0, end: 500.0).animate(CurvedAnimation(
        parent: sliderAnimationController, curve: Curves.bounceOut));
  }

  Widget content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 60.0,
                ),
                Text(
                  'REGISTRATION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.0),
                ),
                FloatingActionButton(
                  tooltip: "What should I do?",
                  mini: true,
                  onPressed: () {
                    _showInformation();
                  },
                  child: Icon(Icons.help_outline),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          child: Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 24.0, bottom: 24.0),
                    child: Center(
                      child: Text(
                        helperText,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    padding: EdgeInsets.only(bottom: 24.0),
                    curve: Curves.bounceInOut,
                    width: double.infinity,
                    child: qrData != ''
                        ? PinField(callback: (p) => pinFilledIn(p))
                        : null,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Scanner(
            callback: (qr) => gotQrData(qr),
            context: context,
          ),
          Align(alignment: Alignment.bottomCenter, child: content()),
          // Align(
          //   alignment: Alignment.bottomRight,
          //   child: FloatingActionButton(
          //     tooltip: "What should I do?",
          //     onPressed: () {
          //       _showInformation();
          //     },
          //     child: Icon(Icons.help_outline),
          //   ),
          // )
        ],
      ),
    );
  }

  gotQrData(value) async {
    setState(() {
      qrData = jsonDecode(value);
    });

    var hash = qrData['hash'];
    var privateKey = qrData['privateKey'];
    var doubleName = qrData['doubleName'];
    var email = qrData['email'];
    var phrase = qrData['phrase'];
    if (hash == null ||
        privateKey == null ||
        doubleName == null ||
        email == null ||
        phrase == null) {
      showError();
    } else {
      var signedDeviceId = signData(deviceId, privateKey);
      sendScannedFlag(hash, await signedDeviceId).then((response) {
        sliderAnimationController.forward();
        setState(() {
          helperText = "Choose new pin";
        });
      }).catchError((e) {
        print(e);
        showError();
      });
    }
  }

  showError() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Something went wrong, please try again later.'),
    ));
  }

  pinFilledIn(String value) async {
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
      scope['doubleName'] = qrData['doubleName'];

      if (qrData['scope'] != null) {
        if (qrData['scope'].contains('user:email')) {
          scope['email'] = {'email': qrData['email'], 'verified': false};
        }

        if (qrData['scope'].contains('user:keys')) {
          scope['keys'] = {'keys': qrData['keys']};
        }
      }
      

      // initialize scopePermissions
      saveScopePermissions(jsonEncode(HashMap()));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PreferenceDialog(
            scope,
            qrData['appId'],
            saveValues,
          );
        },
      );
    }
  }

  saveValues() async {
    logger.log('save values');
    var hash = qrData['hash'];
    var privateKey = qrData['privateKey'];
    var doubleName = qrData['doubleName'];
    var email = qrData['email'];
    var publicKey = qrData['appPublicKey'];
    var phrase = qrData['phrase'];

    savePin(pin);
    savePrivateKey(privateKey);
    savePublicKey(publicKey);
    saveEmail(email, false);
    saveDoubleName(doubleName);
    savePhrase(phrase);

    var signedHash = signData(hash, privateKey);
    var data = encrypt(jsonEncode(scope), publicKey, privateKey);

    sendData(hash, await signedHash, await data, null).then((x) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.of(context).pushNamed('/success');
    });
  }

  _showInformation() {
    var _stepsList =
        'Step 1: Go to the website: https://www.freeflowpages.com/  \n' +
            'Step 2: Create an account\n' +
            'Step 3: Scan the QR code\n';

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: "Steps",
        description: new Text(
          _stepsList,
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
        ),
        actions: <Widget>[
          FlatButton(
            child: new Text("Continue"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
