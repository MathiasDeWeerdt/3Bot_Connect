import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import 'package:threebotlogin/services/openKYCService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

class PreferenceScreen extends StatefulWidget {
  final Widget preferenceScreen;
  PreferenceScreen({Key key, this.preferenceScreen}) : super(key: key);
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  Map email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: PreferencePage([
        PreferenceTitle('General'),
        PreferencePageLink(
          'Key Phrase',
          leading: Icon(Icons.vpn_key),
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceTitle('Write this down on a piece of paper'),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10)),
                padding: EdgeInsets.all(12),
                child: Text(
                  "Show my Key Phrase",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  _showPhrase();
                },
              ),
            ),
          ]),
        ),
        _showResendMail(),
        Container(
            child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              PreferenceTitle('Delete'),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10)),
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
              )
            ],
          ),
        ))
      ]),
    );
  }

  Widget _showResendMail() {
    getEmail().then((emailMap) {
      setState(() {
        email = emailMap;
      });
    });

    bool showButton;
    if (!(email['verified'])) {
      showButton = true;
      return Visibility(
          visible: showButton,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: RaisedButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10)),
              padding: EdgeInsets.all(12),
              child: Text(
                "Resend Verification Mail",
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                sendVerificationEmail();
              },
            ),
          ));
    } else {
      showButton = false;
      return Visibility(
          visible: showButton,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: RaisedButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10)),
              padding: EdgeInsets.all(12),
              child: Text(
                "Resend Verification Mail",
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {},
            ),
          ));
    }
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
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    setState(() {});
                  },
                ),
              ],
            ));
  }

  void _showPhrase() async {
    final phrase = await getPhrase();

    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              image: Icons.error,
              title: "Please write this down on a piece of paper",
              description: new Text(phrase.toString()),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: new Text("Continue"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  void sendVerificationEmail() async {
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
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                ),
              ],
            ));
  }
}
