import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/widgets/PinField.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/connectionService.dart';

class LoginScreen extends StatefulWidget {
  final Widget loginScreen;
  final message;
  final bool closeWhenLoggedIn;

  LoginScreen(this.message, {Key key, this.loginScreen, this.closeWhenLoggedIn = false}) : super(key: key);

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
                                padding: EdgeInsets.only(top: 24.0, bottom: 24.0),
                                child: Center(child: Text(helperText, style: TextStyle(fontSize: 16.0),))),
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
      print("Close when logged in is ${widget.closeWhenLoggedIn}");
      if(widget.closeWhenLoggedIn) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        Navigator.pushReplacementNamed(context, '/success');
      }
    } else {
      print('pin NOK');
      setState(() {
        helperText = "Pin code not ok";
      });
    }
  }
}
