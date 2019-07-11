import 'package:flutter/material.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key}) : super(key: key);
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String doubleName = '';
  Map email;

  @override
  void initState() {
    super.initState();
    getUserValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
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
                    child: Container(
                        padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Container(),
                              ),
                              Icon(
                                Icons.person,
                                size: 42.0,
                                color: Theme.of(context).accentColor,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text('Hi ' + doubleName),
                              Text(
                                  'If you need to login you\'ll get a notification.'),
                              SizedBox(
                                height: 24.0,
                              ),
                              email != null
                                  ? Text(email['email'])
                                  : Container(),
                              email != null && email['verified']
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).accentColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0)),
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                        Text('Email verified.')
                                      ],
                                    )
                                  : email != null
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .errorColor,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0)),
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                    Text(
                                                        'Email not verified, yet.'),
                                                  ],
                                                ),
                                                RaisedButton(
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  10)),
                                                  padding: EdgeInsets.all(3),
                                                  child: Text(
                                                    "Resend verification mail",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                  onPressed: () {
                                                    // Send email.
                                                    sendVerificationEmail();
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      : Container(),
                              SizedBox(
                                height: 48.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    RaisedButton(
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(10)),
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        "Delete account",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Theme.of(context).errorColor,
                                      onPressed: () {
                                        _showDialog();
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))))));
  }

  void getUserValues() {
    getDoubleName().then((dn) {
      setState(() {
        doubleName = dn;
      });
    });
    getEmail().then((emailMap) {
      setState(() {
        email = emailMap;
      });
    });
  }

  void sendVerificationEmail() async {
    var response = await resendVerificationEmail();
    print(response);

    _showResetEmailDialog();
  }

  void _showResetEmailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              image: Icons.check,
              title: "Email has been resend.",
              description: new Text("A new verification email has been send."),
              actions: <Widget>[
                FlatButton(
                  child: new Text("Ok"),
                  onPressed: () {
                    // clearData();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                ),
              ],
            ));
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              image: Icons.error,
              title: "Are you sure?",
              description: new Text(
                  "If you continue, you won't be able to login with the current account again (for now). However, this acccount still exists."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: new Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: new Text("Continue"),
                  onPressed: () async {
                    await clearData();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    setState(() {});
                  },
                ),
              ],
            ));
  }
}
