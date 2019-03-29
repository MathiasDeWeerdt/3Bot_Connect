import 'package:flutter/material.dart';
import 'package:threebotlogin_app/screens/HomeScreen.Dart';
import 'package:threebotlogin_app/widgets/PinField.dart';
import 'package:threebotlogin_app/services/userService.dart';
import 'package:threebotlogin_app/services/cryptoService.dart';
import 'package:threebotlogin_app/services/connectionService.dart';

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
        appBar: new AppBar(
          title: new Text('Login'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(helperText), PinField(callback: (p) => pinFilledIn(p))],
        )));
  }

  pinFilledIn(p) async {
    print(widget.message);
    final pin = await getPin();
    if (pin == p) {
      print('pin OK');
      final hash = widget.message['hash'];
      var signedHash = await signHash(hash);
      sendSignedHash(hash, signedHash);
      Navigator.pop(context,MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      print('pin NOK');
      setState(() {
        helperText = "Pin code not ok";
        //  TODO: count attempts
      });
    }
  }
}
