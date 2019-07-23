import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/HomeScreen.dart';
import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

class PreferenceScreen extends StatefulWidget {
  PreferenceScreen({Key key}) : super(key: key);
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  Map email;
  String doubleName = '';
  String phrase = '';
  bool emailunVerified = false;
  bool showAdvancedOptions = false;
  Icon showAdvancedOptionsIcon = Icon(Icons.keyboard_arrow_up);
  String emailAdress = '';

  @override
  void initState() {
    super.initState();
    getUserValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showAdvancedOptions = false;
            Navigator.pop(context);
          },
        ),
        title: Text('Preferences'),
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Profile",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.green),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                  child: Align(
                      child: Icon(Icons.person),
                      alignment: Alignment.centerLeft),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(doubleName, textAlign: TextAlign.center),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                      child: Icon(Icons.mail), alignment: Alignment.centerLeft),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(emailAdress, textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: (emailunVerified)
                      ? Container()
                      : Text(
                          "(unverified)",
                          style: TextStyle(color: Colors.grey),
                        ),
                ),
                Expanded(
                  child: (emailunVerified)
                      ? Container()
                      : Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: () {
                              sendVerificationEmail();
                            },
                          ),
                        ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                      child: Icon(Icons.vpn_key),
                      alignment: Alignment.centerLeft),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text("Key Phrase", textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () {
                        _showPhrase();
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Advanced Options",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: showAdvancedOptionsIcon,
                      onPressed: () {
                        setState(() {
                          if (!showAdvancedOptions) {
                            showAdvancedOptions = true;
                            showAdvancedOptionsIcon =
                                Icon(Icons.keyboard_arrow_down);
                          } else {
                            showAdvancedOptions = false;
                            showAdvancedOptionsIcon =
                                Icon(Icons.keyboard_arrow_up);
                          }
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Visibility(
              visible: showAdvancedOptions,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Align(
                            child: Icon(Icons.remove_circle),
                            alignment: Alignment.centerLeft),
                      ),
                      FlatButton(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Remove Account From Device",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          _showDialog();
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: "Are you sure?",
            description: new Text(
                "If you continue, you won't be able to login with the current account again (for now). However, this acccount still exists."),
            actions: <Widget>[
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
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                  // setState(() {});
                },
              ),
            ],
          ),
    );
  }

  void sendVerificationEmail() async {
    print("test");
    var response = await resendVerificationEmail();
    print(response);

    _showResendEmailDialog();
  }

  void _showResendEmailDialog() {
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
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _showPhrase() async {
    final phrase = await getPhrase();

    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            image: Icons.create,
            title: "Please write this down on a piece of paper",
            description: new Text(
              phrase.toString(),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
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

  void getUserValues() {
    getDoubleName().then((dn) {
      setState(() {
        doubleName = dn;
      });
    });
    getEmail().then((emailMap) {
      setState(() {
        email = emailMap;
        if (email['email'] != null || email['verified']) {
          emailAdress = email['email'];
          emailunVerified = email['verified'];
        }
      });
    });
    getPhrase().then((seedPhrase) {
      setState(() {
        phrase = seedPhrase;
      });
    });
  }
}
