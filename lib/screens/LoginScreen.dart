import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/connectionService.dart';

class LoginScreen extends StatefulWidget {
  final Widget loginScreen;
  final message;

  LoginScreen({Key key, this.message, this.loginScreen}) : super(key: key);

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
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Container(
                        padding: EdgeInsets.only(top: 24, bottom: 38),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(helperText),
                              PinField(callback: (p) => pinFilledIn(p))
                            ],
                          ),
                        ))))));
  }

  pinFilledIn(p) async {
    print(widget.message);
    final pin = await getPin();
    print(pin);
    print(p);
    if (pin == p) {
      print('pin OK');
      final hash = widget.message['hash'];
      var signedHash = await signHash(hash, await getPrivateKey());
      sendSignedHash(hash, signedHash);
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      print('pin NOK');
      setState(() {
        helperText = "Pin code not ok";
      });
    }
  }
}
