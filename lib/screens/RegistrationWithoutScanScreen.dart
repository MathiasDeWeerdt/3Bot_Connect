import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/connectionService.dart';
import 'package:threebotlogin/main.dart';

class RegistrationWithoutScanScreen extends StatefulWidget {
  final Widget registrationWithoutScanScreen;
  final message;
  final initialData;
  RegistrationWithoutScanScreen(this.initialData, {Key key, this.message, this.registrationWithoutScanScreen}) : super(key: key);

  _RegistrationWithoutScanScreen createState() => _RegistrationWithoutScanScreen();
}

class _RegistrationWithoutScanScreen extends State<RegistrationWithoutScanScreen> {
  String helperText = 'Choose new pin';
  String pin;
  @override 
  void initState() {
    super.initState();
    sendScannedFlag(widget.initialData['hash'], deviceId);
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
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Container(
                        padding: EdgeInsets.only(top: 24, bottom: 38),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(top: 24, bottom: 24),
                                child: Center(child: Text(helperText, style: TextStyle(fontSize: 16),))),
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
      var hash = widget.initialData['hash'];
      var privateKey = widget.initialData['privateKey'];
      savePin(value);
      savePrivateKey(privateKey);
      var signedHash = signHash(hash, privateKey);
      sendSignedHash(hash, await signedHash);
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }
}
