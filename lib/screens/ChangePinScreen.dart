import 'package:flutter/material.dart';
import 'package:threebotlogin/services/userService.dart';

import 'package:threebotlogin/widgets/PinField.dart';

class ChangePinScreen extends StatefulWidget {
  ChangePinScreen({Key key}) : super(key: key);
  _ChangePinScreenState createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  bool pinChanged = false;
  bool oldPinOk = false;
  String helperText = 'Enter old pincode';
  var newPin;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text("Change pincode"),
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
              padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 0.0, bottom: 32.0),
                      child: Center(
                          child: Text(
                        helperText,
                        style: TextStyle(fontSize: 24.0),
                      )),
                    ),
                    !pinChanged
                        ? PinField(
                            callback: (p) => changePin(p),
                          )
                        : succesfulChange(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  changePin(p) async {
    final oldPin = await getPin();

    if (!oldPinOk) {
      if (oldPin == p) {
        setState(() {
          helperText = "Enter new pincode";
          oldPinOk = true;
        });
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Oops... you entered the wrong pin'),
            duration: Duration(milliseconds: 500)));
      }
    } else {
      if (newPin == null) {
        setState(() {
          newPin = p;
          helperText = "Confirm new pincode";
        });
      } else {
        if (newPin == p) {
          savePin(newPin);
          setState(() {
            helperText = '';
            pinChanged = true;
          });
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Oops... pin does not match'),
              duration: Duration(milliseconds: 500)));
        }
      }
    }
  }

  Widget succesfulChange() {
    return Container(
        child: Column(
      children: <Widget>[
        Text(
          'Pincode Succesfully',
          style: TextStyle(fontSize: 32),
        ),
        Container(
          padding: EdgeInsets.all(20.0),
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
        ),
        RaisedButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          child: Text(
            'Close',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.green,
        )
      ],
    ));
  }
}
